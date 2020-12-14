import 'package:json_api/codec.dart';
import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/query.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/document/inbound_document.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/server/_internal/relationship_node.dart';
import 'package:json_api/src/server/_internal/repo.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/json_api_response.dart';

class RepositoryController implements Controller<JsonApiResponse> {
  RepositoryController(this.repo, this.getId);

  final Repo repo;

  final IdGenerator getId;

  final design = StandardUriDesign.pathOnly;

  @override
  Future<JsonApiResponse> fetchCollection(
      HttpRequest request, Target target) async {
    final resources = await _fetchAll(target.type).toList();
    final doc = OutboundDataDocument.collection(resources)
      ..links['self'] = Link(design.collection(target.type));
    final forest = RelationshipNode.forest(Include.fromUri(request.uri));
    for (final r in resources) {
      await for (final r in _getAllRelated(r, forest)) {
        doc.included.add(r);
      }
    }
    return JsonApiResponse.ok(doc);
  }

  @override
  Future<JsonApiResponse> fetchResource(
      HttpRequest request, ResourceTarget target) async {
    final resource = await _fetchLinkedResource(target.type, target.id);
    final doc = OutboundDataDocument.resource(resource)
      ..links['self'] = Link(design.resource(target.type, target.id));
    final forest = RelationshipNode.forest(Include.fromUri(request.uri));
    await for (final r in _getAllRelated(resource, forest)) {
      doc.included.add(r);
    }
    return JsonApiResponse.ok(doc);
  }

  @override
  Future<JsonApiResponse> createResource(
      HttpRequest request, Target target) async {
    final res = (await _decode(request)).dataAsNewResource();
    final ref = Ref(res.type, res.id ?? getId());
    await repo.persist(
        res.type, Model(ref.id)..setFrom(ModelProps.fromResource(res)));
    if (res.id != null) {
      return JsonApiResponse.noContent();
    }
    final self = Link(design.resource(ref.type, ref.id));
    final resource = (await _fetchResource(ref.type, ref.id))
      ..links['self'] = self;
    return JsonApiResponse.created(
        OutboundDataDocument.resource(resource)..links['self'] = self,
        self.uri.toString());
  }

  @override
  Future<JsonApiResponse> addMany(
      HttpRequest request, RelationshipTarget target) async {
    final many = (await _decode(request)).asRelationship<ToMany>();
    final refs = await repo
        .addMany(target.type, target.id, target.relationship, many)
        .toList();
    return JsonApiResponse.ok(
        OutboundDataDocument.many(ToMany(refs.map(Identifier.of))));
  }

  @override
  Future<JsonApiResponse> deleteResource(
      HttpRequest request, ResourceTarget target) async {
    await repo.delete(target.type, target.id);
    return JsonApiResponse.noContent();
  }

  @override
  Future<JsonApiResponse> updateResource(
      HttpRequest request, ResourceTarget target) async {
    await repo.update(target.type, target.id,
        ModelProps.fromResource((await _decode(request)).dataAsResource()));
    return JsonApiResponse.noContent();
  }

  @override
  Future<JsonApiResponse> replaceRelationship(
      HttpRequest request, RelationshipTarget target) async {
    final rel = (await _decode(request)).asRelationship();
    if (rel is ToOne) {
      final ref = rel.identifier;
      await repo.replaceOne(target.type, target.id, target.relationship, ref);
      return JsonApiResponse.ok(OutboundDataDocument.one(
          ref == null ? ToOne.empty() : ToOne(Identifier.of(ref))));
    }
    if (rel is ToMany) {
      final ids = await repo
          .replaceMany(target.type, target.id, target.relationship, rel)
          .map(Identifier.of)
          .toList();
      return JsonApiResponse.ok(OutboundDataDocument.many(ToMany(ids)));
    }
    throw FormatException('Incomplete relationship');
  }

  @override
  Future<JsonApiResponse> deleteMany(
      HttpRequest request, RelationshipTarget target) async {
    final rel = (await _decode(request)).asToMany();
    final ids = await repo
        .deleteMany(target.type, target.id, target.relationship, rel)
        .map(Identifier.of)
        .toList();
    return JsonApiResponse.ok(OutboundDataDocument.many(ToMany(ids)));
  }

  @override
  Future<JsonApiResponse> fetchRelationship(
      HttpRequest request, RelationshipTarget target) async {
    final model = (await repo.fetch(target.type, target.id));

    if (model.one.containsKey(target.relationship)) {
      return JsonApiResponse.ok(OutboundDataDocument.one(
          ToOne(nullable(Identifier.of)(model.one[target.relationship]))));
    }
    final many = model.many[target.relationship];
    if (many != null) {
      final doc = OutboundDataDocument.many(ToMany(many.map(Identifier.of)));
      return JsonApiResponse.ok(doc);
    }
    throw RelationshipNotFound();
  }

  @override
  Future<JsonApiResponse> fetchRelated(
      HttpRequest request, RelatedTarget target) async {
    final model = await repo.fetch(target.type, target.id);
    if (model.one.containsKey(target.relationship)) {
      final related =
          await nullable(_fetchRelatedResource)(model.one[target.relationship]);
      final doc = OutboundDataDocument.resource(related);
      return JsonApiResponse.ok(doc);
    }
    if (model.many.containsKey(target.relationship)) {
      final many = model.many[target.relationship] ?? {};
      final doc = OutboundDataDocument.collection(
          await _fetchRelatedCollection(many).toList());
      return JsonApiResponse.ok(doc);
    }
    throw RelationshipNotFound();
  }

  /// Returns a stream of related resources recursively
  Stream<Resource> _getAllRelated(
      Resource resource, Iterable<RelationshipNode> forest) async* {
    for (final node in forest) {
      await for (final r in _getRelated(resource, node.name)) {
        yield r;
        yield* _getAllRelated(r, node.children);
      }
    }
  }

  /// Returns a stream of related resources
  Stream<Resource> _getRelated(Resource resource, String relationship) async* {
    for (final _ in resource.relationships[relationship] ??
        (throw RelationshipNotFound())) {
      yield await _fetchLinkedResource(_.type, _.id);
    }
  }

  /// Fetches and builds a resource object with a "self" link
  Future<Resource> _fetchLinkedResource(String type, String id) async {
    return (await _fetchResource(type, id))
      ..links['self'] = Link(design.resource(type, id));
  }

  Stream<Resource> _fetchAll(String type) =>
      repo.fetchCollection(type).map((_) => _.toResource(type));

  /// Fetches and builds a resource object
  Future<Resource> _fetchResource(String type, String id) async {
    return (await repo.fetch(type, id)).toResource(type);
  }

  Future<Resource?> _fetchRelatedResource(Ref ref) {
    return _fetchLinkedResource(ref.type, ref.id);
  }

  Stream<Resource> _fetchRelatedCollection(Iterable<Ref> refs) async* {
    for (final ref in refs) {
      final r = await _fetchRelatedResource(ref);
      if (r != null) yield r;
    }
  }

  Future<InboundDocument> _decode(HttpRequest r) async =>
      InboundDocument(await DefaultCodec().decode(r.body));
}

typedef IdGenerator = String Function();
