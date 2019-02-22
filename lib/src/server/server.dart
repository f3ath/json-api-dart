import 'dart:convert';

import 'package:json_api/resource.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/server/request.dart';
import 'package:json_api/src/server/resource_controller.dart';
import 'package:json_api/src/server/response.dart';
import 'package:json_api/src/server/routing.dart';
import 'package:json_api/src/transport/collection_document.dart';
import 'package:json_api/src/transport/identifier_envelope.dart';
import 'package:json_api/src/transport/link.dart';
import 'package:json_api/src/transport/relationship.dart';
import 'package:json_api/src/transport/resource_envelope.dart';
import 'package:json_api/src/transport/resource_document.dart';

class JsonApiServer implements JsonApiController {
  final ResourceController resource;
  final Routing routing;

  JsonApiServer(this.resource, this.routing);

  Future<ServerResponse> handle(String method, Uri uri, String body) async {
    final jsonApiRequest = await routing.resolve(method, uri, body);
    if (jsonApiRequest == null || !resource.supports(jsonApiRequest.type)) {
      return ServerResponse(404);
    }
    return jsonApiRequest.fulfill(this);
  }

  Future<ServerResponse> fetchCollection(CollectionRequest rq) async {
    final collection = await resource.fetchCollection(rq.type, rq.params);

    final pagination = Pagination.fromMap(collection.page.mapPages(
        (_) => Link(routing.collection(rq.type, params: _?.parameters))));

    final doc = CollectionDocument(
        collection.elements.map(enclose).toList(),
        self: Link(
            routing.collection(rq.type, params: collection.page?.parameters)),
        pagination: pagination);
    return ServerResponse.ok(doc);
  }

  ResourceEnvelope enclose(Resource r) {
    final toOne = r.toOne.map((name, v) => MapEntry(
        name,
        ToOne(nullable(IdentifierEnvelope.fromIdentifier)(v),
            self: Link(routing.relationship(r.type, r.id, name)),
            related: Link(routing.related(r.type, r.id, name)))));

    final toMany = r.toMany.map((name, v) => MapEntry(
        name,
        ToMany(v.map(nullable(IdentifierEnvelope.fromIdentifier)).toList(),
            self: Link(routing.relationship(r.type, r.id, name)),
            related: Link(routing.related(r.type, r.id, name)))));
    return ResourceEnvelope(r.type, r.id,
        attributes: r.attributes,
        self: Link(routing.resource(r.type, r.id)),
        relationships: <String, Relationship>{}..addAll(toOne)..addAll(toMany));
  }

//
//  Future<ServerResponse> fetchResource(ResourceRequest rq) async {
//    final res = await _resource(rq.identifier);
//    return ServerResponse.ok(
//        ResourceDocument(res == null ? null : _addResourceLinks(res)));
//  }
//
  Future<ServerResponse> fetchRelated(RelatedRequest rq) async {
    final res =
        await resource.fetchResources([Identifier(rq.type, rq.id)]).first;

    if (res.toOne.containsKey(rq.relName)) {
      final id = res.toOne[rq.relName];
      // TODO check if id == null
      final related = await resource.fetchResources([id]).first;
      return ServerResponse.ok(ResourceDocument(enclose(related)));
    }

    if (res.toMany.containsKey(rq.relName)) {
      final ids = res.toMany[rq.relName];
      final related = await resource.fetchResources(ids).toList();
      return ServerResponse.ok(
          CollectionDocument(related.map(enclose).toList()));
    }

    // TODO return 404
    throw StateError('');
  }

  Future<ServerResponse> fetchRelationship(RelationshipRequest rq) async {
    final res = await _resource(rq.identifier);
    final rel = res.relationships[rq.name];
    return ServerResponse.ok(
        _addRelationshipLinks(rel, rq.type, rq.id, rq.name));
  }

  Future<ServerResponse> createResource(CollectionRequest rq) async {
    final doc = ResourceDocument.fromJson(json.decode(rq.body));
    await resource.createResource(doc.resource.toResource());
    return ServerResponse(204);
  }

  Future<ServerResponse> addRelationship(RelationshipRequest rq) async {
    final rel = Relationship.fromJson(json.decode(rq.body));
    if (rel is ToMany) {
      await resource.mergeToMany(rq.identifier, rq.name, rel);
      final res = await _resource(rq.identifier);
      return ServerResponse.ok(_addRelationshipLinks(
          res.relationships[rq.name], rq.type, rq.id, rq.name));
    }
    // TODO: Return a meaningful response
    return null;
  }

  Future<Resource> _resource(Identifier id) =>
      resource.fetchResources([id]).first;

}
