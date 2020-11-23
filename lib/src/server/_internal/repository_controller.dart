import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/query.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/server/_internal/relationship_node.dart';
import 'package:json_api/src/server/_internal/repo.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/response.dart';

class RepositoryController implements Controller {
  RepositoryController(this.repo, this.getId);

  final Repo repo;

  final IdGenerator getId;

  final urlDesign = RecommendedUrlDesign.pathOnly;

  @override
  Future<HttpResponse> fetchCollection(
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
    return Response.ok(doc);
  }

  @override
  Future<HttpResponse> fetchResource(
      HttpRequest request, ResourceTarget target) async {
    final resource = await _fetchLinkedResource(target.type, target.id);
    if (resource == null) return Response.notFound();
    final doc = OutboundDataDocument.resource(resource)
      ..links['self'] = Link(target.map(urlDesign));
    final forest = RelationshipNode.forest(Include.fromUri(request.uri));
    await for (final r in _getAllRelated(resource, forest)) {
      doc.included.add(r);
    }
    return Response.ok(doc);
  }

  @override
  Future<HttpResponse> createResource(
      HttpRequest request, CollectionTarget target) async {
    final res = _decode(request).newResource();
    final id = res.id ?? getId();
    await repo.persist(res.type, id, _toModel(res));
    if (res.id != null) {
      return Response.noContent();
    }
    final self = Link(ResourceTarget(target.type, id).map(urlDesign));
    final resource = await _fetchResource(target.type, id)
      ..links['self'] = self;
    return Response.created(
        OutboundDataDocument.resource(resource)..links['self'] = self,
        self.uri.toString());
  }

  @override
  Future<HttpResponse> addMany(
      HttpRequest request, RelationshipTarget target) async {
    final many = _decode(request).dataAsRelationship<Many>();
    final refs = await repo
        .addMany(
            target.type, target.id, target.relationship, many.map((_) => _.key))
        .toList();
    return Response.ok(
        OutboundDataDocument.many(Many(refs.map(Identifier.fromKey))));
  }

  @override
  Future<HttpResponse> deleteResource(
      HttpRequest request, ResourceTarget target) async {
    await repo.delete(target.type, target.id);
    return Response.noContent();
  }

  @override
  Future<HttpResponse> updateResource(
      HttpRequest request, ResourceTarget target) async {
    await repo.update(
        target.type, target.id, _toModel(_decode(request).resource()));
    return Response.noContent();
  }

  @override
  Future<HttpResponse> replaceRelationship(
      HttpRequest request, RelationshipTarget target) async {
    final rel = _decode(request).dataAsRelationship();
    if (rel is One) {
      final id = rel.identifier;
      if (id == null) {
        await repo.deleteOne(target.type, target.id, target.relationship);
      } else {
        await repo.replaceOne(
            target.type, target.id, target.relationship, id.key);
      }
      return Response.ok(OutboundDataDocument.one(One(id)));
    }
    if (rel is Many) {
      final ids = await repo
          .replaceMany(target.type, target.id, target.relationship,
              rel.map((_) => _.key))
          .map(Identifier.fromKey)
          .toList();
      return Response.ok(OutboundDataDocument.many(Many(ids)));
    }
    throw FormatException('Incomplete relationship');
  }

  @override
  Future<HttpResponse> deleteMany(
      HttpRequest request, RelationshipTarget target) async {
    final rel = _decode(request).dataAsRelationship<Many>();
    final ids = await repo
        .deleteMany(
            target.type, target.id, target.relationship, rel.map((_) => _.key))
        .map(Identifier.fromKey)
        .toList();
    return Response.ok(OutboundDataDocument.many(Many(ids)));
  }

  @override
  Future<HttpResponse> fetchRelationship(
      HttpRequest request, RelationshipTarget target) async {
    final model = await repo.fetch(target.type, target.id);
    if (model.one.containsKey(target.relationship)) {
      final doc = OutboundDataDocument.one(
          One(nullable(Identifier.fromKey)(model.one[target.relationship])));
      return Response.ok(doc);
    }
    if (model.many.containsKey(target.relationship)) {
      final doc = OutboundDataDocument.many(
          Many(model.many[target.relationship].map(Identifier.fromKey)));
      return Response.ok(doc);
    }
    // TODO: implement fetchRelationship
    throw UnimplementedError();
  }

  @override
  Future<HttpResponse> fetchRelated(
      HttpRequest request, RelatedTarget target) async {
    final model = await repo.fetch(target.type, target.id);
    if (model.one.containsKey(target.relationship)) {
      final related =
          await _fetchRelatedResource(model.one[target.relationship]);
      final doc = OutboundDataDocument.resource(related);
      return Response.ok(doc);
    }
    if (model.many.containsKey(target.relationship)) {
      final doc = OutboundDataDocument.collection(
          await _fetchRelatedCollection(model.many[target.relationship])
              .toList());
      return Response.ok(doc);
    }
    // TODO: implement fetchRelated
    throw UnimplementedError();
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
    for (final _ in resource.relationships[relationship]) {
      final r = await _fetchLinkedResource(_.type, _.id);
      if (r != null) yield r;
    }
  }

  /// Fetches and builds a resource object with a "self" link
  Future<Resource /*?*/ > _fetchLinkedResource(String type, String id) async {
    final r = await _fetchResource(type, id);
    if (r == null) return null;
    return r..links['self'] = Link(ResourceTarget(type, id).map(urlDesign));
  }

  Stream<Resource> _fetchAll(String type) =>
      repo.fetchCollection(type).map((e) => _toResource(e.id, type, e.model));

  /// Fetches and builds a resource object
  Future<Resource /*?*/ > _fetchResource(String type, String id) async {
    final model = await repo.fetch(type, id);
    if (model == null) return null;
    return _toResource(id, type, model);
  }

  Future<Resource /*?*/ > _fetchRelatedResource(String key) {
    final id = Identifier.fromKey(key);
    return _fetchLinkedResource(id.type, id.id);
  }

  Stream<Resource> _fetchRelatedCollection(Iterable<String> keys) async* {
    for (final key in keys) {
      yield await _fetchRelatedResource(key);
    }
  }

  Resource _toResource(String id, String type, Model model) {
    final res = Resource(type, id);
    model.attributes.forEach((key, value) {
      res.attributes[key] = value;
    });
    model.one.forEach((key, value) {
      res.relationships[key] = One(nullable(Identifier.fromKey)(value));
    });
    model.many.forEach((key, value) {
      res.relationships[key] = Many(value.map((Identifier.fromKey)));
    });
    return res;
  }

  Model _toModel(ResourceProperties r) {
    final model = Model();
    r.attributes.forEach((key, value) {
      model.attributes[key] = value;
    });
    r.relationships.forEach((key, value) {
      if (value is One) {
        model.one[key] = value?.identifier?.key;
      }
      if (value is Many) {
        model.many[key] = Set.from(value.map((_) => _.key));
      }
    });
    return model;
  }

  InboundDocument _decode(HttpRequest r) => InboundDocument.decode(r.body);
}

typedef IdGenerator = String Function();
