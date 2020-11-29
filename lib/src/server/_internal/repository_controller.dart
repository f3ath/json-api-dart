import 'package:json_api/core.dart';
import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/query.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/server/_internal/relationship_node.dart';
import 'package:json_api/src/server/_internal/repo.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/json_api_response.dart';

class RepositoryController implements Controller<JsonApiResponse> {
  RepositoryController(this.repo, this.getId);

  final Repo repo;

  final IdGenerator getId;

  final urlDesign = RecommendedUrlDesign.pathOnly;

  @override
  Future<JsonApiResponse> fetchCollection(
      HttpRequest request, CollectionTarget target) async {
    final resources = await _fetchAll(target.type).toList();
    final doc = OutboundDataDocument.collection(resources)
      ..links['self'] = Link(target.map(urlDesign));
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
    final resource = await _fetchLinkedResource(target.ref);
    final doc = OutboundDataDocument.resource(resource)
      ..links['self'] = Link(target.map(urlDesign));
    final forest = RelationshipNode.forest(Include.fromUri(request.uri));
    await for (final r in _getAllRelated(resource, forest)) {
      doc.included.add(r);
    }
    return JsonApiResponse.ok(doc);
  }

  @override
  Future<JsonApiResponse> createResource(
      HttpRequest request, CollectionTarget target) async {
    final res = _decode(request).newResource();
    final ref = Ref(res.type, res.id ?? getId());
    await repo.persist(Model(ref)..setFrom(res.toModelProps()));
    if (res.id != null) {
      return JsonApiResponse.noContent();
    }
    final self = Link(ResourceTarget(ref).map(urlDesign));
    final resource = (await _fetchResource(ref))..links['self'] = self;
    return JsonApiResponse.created(
        OutboundDataDocument.resource(resource)..links['self'] = self,
        self.uri.toString());
  }

  @override
  Future<JsonApiResponse> addMany(
      HttpRequest request, RelationshipTarget target) async {
    final many = _decode(request).dataAsRelationship<ToMany>();
    final refs = await repo
        .addMany(target.ref, target.relationship, many.map((_) => _.ref))
        .toList();
    return JsonApiResponse.ok(
        OutboundDataDocument.many(ToMany(refs.map(_toIdentifier))));
  }

  @override
  Future<JsonApiResponse> deleteResource(
      HttpRequest request, ResourceTarget target) async {
    await repo.delete(target.ref);
    return JsonApiResponse.noContent();
  }

  @override
  Future<JsonApiResponse> updateResource(
      HttpRequest request, ResourceTarget target) async {
    await repo.update(target.ref, _decode(request).resource().toModelProps());
    return JsonApiResponse.noContent();
  }

  @override
  Future<JsonApiResponse> replaceRelationship(
      HttpRequest request, RelationshipTarget target) async {
    final rel = _decode(request).dataAsRelationship();
    if (rel is ToOne) {
      final ref = rel.identifier?.ref;
      await repo.replaceOne(target.ref, target.relationship, ref);
      return JsonApiResponse.ok(OutboundDataDocument.one(
          ref == null ? ToOne.empty() : ToOne(Identifier(ref))));
    }
    if (rel is ToMany) {
      final ids = await repo
          .replaceMany(target.ref, target.relationship, rel.map((_) => _.ref))
          .map(_toIdentifier)
          .toList();
      return JsonApiResponse.ok(OutboundDataDocument.many(ToMany(ids)));
    }
    throw FormatException('Incomplete relationship');
  }

  @override
  Future<JsonApiResponse> deleteMany(
      HttpRequest request, RelationshipTarget target) async {
    final rel = _decode(request).dataAsRelationship<ToMany>();
    final ids = await repo
        .deleteMany(target.ref, target.relationship, rel.map((_) => _.ref))
        .map(_toIdentifier)
        .toList();
    return JsonApiResponse.ok(OutboundDataDocument.many(ToMany(ids)));
  }

  @override
  Future<JsonApiResponse> fetchRelationship(
      HttpRequest request, RelationshipTarget target) async {
    final model = (await repo.fetch(target.ref));

    if (model.one.containsKey(target.relationship)) {
      return JsonApiResponse.ok(OutboundDataDocument.one(
          ToOne(nullable(_toIdentifier)(model.one[target.relationship]))));
    }
    final many = model.many[target.relationship];
    if (many != null) {
      final doc = OutboundDataDocument.many(ToMany(many.map(_toIdentifier)));
      return JsonApiResponse.ok(doc);
    }
    // TODO: implement fetchRelationship
    throw UnimplementedError();
  }

  @override
  Future<JsonApiResponse> fetchRelated(
      HttpRequest request, RelatedTarget target) async {
    final model = await repo.fetch(target.ref);
    if (model.one.containsKey(target.relationship)) {
      final related =
          await nullable(_fetchRelatedResource)(model.one[target.relationship]);
      final doc = OutboundDataDocument.resource(related);
      return JsonApiResponse.ok(doc);
    }
    final many = model.many[target.relationship];
    if (many != null) {
      final doc = OutboundDataDocument.collection(
          await _fetchRelatedCollection(many).toList());
      return JsonApiResponse.ok(doc);
    }
    // TODO: implement fetchRelated
    throw UnimplementedError();
  }

  Identifier _toIdentifier(Ref ref) => Identifier(ref);

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
        (throw RelationshipNotFound(relationship))) {
      yield await _fetchLinkedResource(_.ref);
    }
  }

  /// Fetches and builds a resource object with a "self" link
  Future<Resource> _fetchLinkedResource(Ref ref) async {
    return (await _fetchResource(ref))
      ..links['self'] = Link(ResourceTarget(ref).map(urlDesign));
  }

  Stream<Resource> _fetchAll(String type) =>
      repo.fetchCollection(type).map(_toResource);

  /// Fetches and builds a resource object
  Future<Resource> _fetchResource(ref) async {
    return _toResource(await repo.fetch(ref));
  }

  Future<Resource?> _fetchRelatedResource(Ref ref) {
    final id = Identifier(ref);
    return _fetchLinkedResource(ref);
  }

  Stream<Resource> _fetchRelatedCollection(Iterable<Ref> refs) async* {
    for (final ref in refs) {
      final r = await _fetchRelatedResource(ref);
      if (r != null) yield r;
    }
  }

  Resource _toResource(Model model) {
    final res = Resource(model.ref);
    model.attributes.forEach((key, value) {
      res.attributes[key] = value;
    });
    model.one.forEach((key, value) {
      res.relationships[key] =
          (value == null ? ToOne.empty() : ToOne(Identifier(value)));
    });
    model.many.forEach((key, value) {
      res.relationships[key] = ToMany(value.map(_toIdentifier));
    });
    return res;
  }

  InboundDocument _decode(HttpRequest r) => InboundDocument.decode(r.body);
}

typedef IdGenerator = String Function();
