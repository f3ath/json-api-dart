import 'dart:convert';

import 'package:http_interop/extensions.dart';
import 'package:http_interop/http_interop.dart' as http;
import 'package:json_api/document.dart';
import 'package:json_api/query.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/client/payload_codec.dart';
import 'package:json_api/src/nullable.dart';

import 'relationship_node.dart';
import 'repository.dart';

class RepositoryController implements Controller {
  RepositoryController(this.repo, this.getId);

  final Repository repo;

  final IdGenerator getId;

  final design = StandardUriDesign.pathOnly;

  @override
  Future<Response> fetchCollection(http.Request request, Target target) async {
    final resources = await _fetchAll(target.type).toList();
    final doc = OutboundDataDocument.collection(resources)
      ..links['self'] = Link(design.collection(target.type));
    final forest = RelationshipNode.forest(Include.fromUri(request.uri));
    for (final r in resources) {
      await for (final r in _getAllRelated(r, forest)) {
        doc.included.add(r);
      }
    }
    return Response.ok(doc);
  }

  @override
  Future<Response> fetchResource(
      http.Request request, ResourceTarget target) async {
    final resource = await _fetchLinkedResource(target.type, target.id);
    final doc = OutboundDataDocument.resource(resource)
      ..links['self'] = Link(design.resource(target.type, target.id));
    final forest = RelationshipNode.forest(Include.fromUri(request.uri));
    await for (final r in _getAllRelated(resource, forest)) {
      doc.included.add(r);
    }
    return Response.ok(doc);
  }

  @override
  Future<Response> createResource(http.Request request, Target target) async {
    final document = await _decode(request);
    final newResource = document.dataAsNewResource();
    final res = newResource.toResource(getId);
    await repo.persist(
        res.type, Model(res.id)..setFrom(ModelProps.fromResource(res)));
    if (newResource.id != null) {
      return Response.noContent();
    }
    final ref = Reference.of(res.toIdentifier());
    final self = Link(design.resource(ref.type, ref.id));
    final resource = (await _fetchResource(ref.type, ref.id))
      ..links['self'] = self;
    return Response.created(
        OutboundDataDocument.resource(resource)..links['self'] = self,
        self.uri.toString());
  }

  @override
  Future<Response> addMany(
      http.Request request, RelationshipTarget target) async {
    final many = (await _decode(request)).asRelationship<ToMany>();
    final refs = await repo
        .addMany(target.type, target.id, target.relationship, many)
        .toList();
    return Response.ok(OutboundDataDocument.many(ToMany(refs)));
  }

  @override
  Future<Response> deleteResource(
      http.Request request, ResourceTarget target) async {
    await repo.delete(target.type, target.id);
    return Response.noContent();
  }

  @override
  Future<Response> updateResource(
      http.Request request, ResourceTarget target) async {
    await repo.update(target.type, target.id,
        ModelProps.fromResource((await _decode(request)).dataAsResource()));
    return Response.noContent();
  }

  @override
  Future<Response> replaceRelationship(
      http.Request request, RelationshipTarget target) async {
    final rel = (await _decode(request)).asRelationship();
    if (rel is ToOne) {
      final ref = rel.identifier;
      await repo.replaceOne(target.type, target.id, target.relationship, ref);
      return Response.ok(
          OutboundDataDocument.one(ref == null ? ToOne.empty() : ToOne(ref)));
    }
    if (rel is ToMany) {
      final ids = await repo
          .replaceMany(target.type, target.id, target.relationship, rel)
          .toList();
      return Response.ok(OutboundDataDocument.many(ToMany(ids)));
    }
    throw FormatException('Incomplete relationship');
  }

  @override
  Future<Response> deleteMany(
      http.Request request, RelationshipTarget target) async {
    final rel = (await _decode(request)).asToMany();
    final ids = await repo
        .deleteMany(target.type, target.id, target.relationship, rel)
        .toList();
    return Response.ok(OutboundDataDocument.many(ToMany(ids)));
  }

  @override
  Future<Response> fetchRelationship(
      http.Request request, RelationshipTarget target) async {
    final model = (await repo.fetch(target.type, target.id));

    if (model.one.containsKey(target.relationship)) {
      return Response.ok(OutboundDataDocument.one(
          ToOne(model.one[target.relationship]?.toIdentifier())));
    }
    final many =
        model.many[target.relationship]?.map((it) => it.toIdentifier());
    if (many != null) {
      final doc = OutboundDataDocument.many(ToMany(many));
      return Response.ok(doc);
    }
    throw RelationshipNotFound(target.type, target.id, target.relationship);
  }

  @override
  Future<Response> fetchRelated(
      http.Request request, RelatedTarget target) async {
    final model = await repo.fetch(target.type, target.id);
    if (model.one.containsKey(target.relationship)) {
      final related =
          await nullable(_fetchRelatedResource)(model.one[target.relationship]);
      final doc = OutboundDataDocument.resource(related);
      return Response.ok(doc);
    }
    if (model.many.containsKey(target.relationship)) {
      final many = model.many[target.relationship] ?? {};
      final doc = OutboundDataDocument.collection(
          await _fetchRelatedCollection(many).toList());
      return Response.ok(doc);
    }
    throw RelationshipNotFound(target.type, target.id, target.relationship);
  }

  /// Returns a stream of related resources recursively
  Stream<Resource> _getAllRelated(
      Resource resource, Iterable<RelationshipNode> nodes) async* {
    for (final node in nodes) {
      await for (final r in _getRelated(resource, node.name)) {
        yield r;
        yield* _getAllRelated(r, node.children);
      }
    }
  }

  /// Returns a stream of related resources
  Stream<Resource> _getRelated(Resource resource, String relationship) async* {
    for (final _ in resource.relationships[relationship] ??
        (throw RelationshipNotFound(
            resource.type, resource.id, relationship))) {
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

  Future<Resource?> _fetchRelatedResource(Reference ref) {
    return _fetchLinkedResource(ref.type, ref.id);
  }

  Stream<Resource> _fetchRelatedCollection(Iterable<Reference> refs) async* {
    for (final ref in refs) {
      final r = await _fetchRelatedResource(ref);
      if (r != null) yield r;
    }
  }

  Future<InboundDocument> _decode(http.Request r) => r.body
      .decode(utf8)
      .then(const PayloadCodec().decode)
      .then(InboundDocument.new);
}

typedef IdGenerator = String Function();
