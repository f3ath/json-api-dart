import 'dart:async';
import 'dart:convert';

import 'package:json_api/resource.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/server/json_api_controller.dart';
import 'package:json_api/src/server/resource_controller.dart';
import 'package:json_api/src/server/response.dart';
import 'package:json_api/src/server/routing.dart';
import 'package:json_api/src/transport/collection_document.dart';
import 'package:json_api/src/transport/identifier_envelope.dart';
import 'package:json_api/src/transport/link.dart';
import 'package:json_api/src/transport/relationship.dart';
import 'package:json_api/src/transport/resource_document.dart';
import 'package:json_api/src/transport/resource_envelope.dart';

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

  Future<ServerResponse> fetchCollection(
      String type, Map<String, String> params) async {
    final collection = await resource.fetchCollection(type, params);

    final pagination = Pagination.fromMap(collection.page.mapPages(
        (_) => Link(routing.collection(type, params: _?.parameters))));

    final doc = CollectionDocument(collection.elements.map(_enclose).toList(),
        self:
            Link(routing.collection(type, params: collection.page?.parameters)),
        pagination: pagination);
    return ServerResponse.ok(doc);
  }

  Future<ServerResponse> fetchResource(String type, String id) async {
    final res = await _resource(type, id);
    return ServerResponse.ok(ResourceDocument(nullable(_enclose)(res)));
  }

  Future<ServerResponse> fetchRelated(
      String type, String id, String relationship) async {
    final res = await resource.fetchResources([Identifier(type, id)]).first;

    if (res.toOne.containsKey(relationship)) {
      final id = res.toOne[relationship];
      // TODO check if id == null
      final related = await resource.fetchResources([id]).first;
      return ServerResponse.ok(ResourceDocument(_enclose(related)));
    }

    if (res.toMany.containsKey(relationship)) {
      final ids = res.toMany[relationship];
      final related = await resource.fetchResources(ids).toList();
      return ServerResponse.ok(
          CollectionDocument(related.map(_enclose).toList()));
    }

    return ServerResponse.notFound();
  }

  Future<ServerResponse> fetchRelationship(
      String type, String id, String relationship) async {
    final res = await _resource(type, id);
    if (res.toOne.containsKey(relationship)) {
      return ServerResponse.ok(ToOne(
          nullable(IdentifierEnvelope.fromIdentifier)(res.toOne[relationship]),
          self: Link(routing.relationship(res.type, res.id, relationship)),
          related: Link(routing.related(res.type, res.id, relationship))));
    }
    if (res.toMany.containsKey(relationship)) {
      return ServerResponse.ok(ToMany(
          res.toMany[relationship]
              .map(IdentifierEnvelope.fromIdentifier)
              .toList(),
          self: Link(routing.relationship(res.type, res.id, relationship)),
          related: Link(routing.related(res.type, res.id, relationship))));
    }
    return ServerResponse.notFound();
  }

  Future<ServerResponse> createResource(String body) async {
    final doc = ResourceDocument.fromJson(json.decode(body));
    await resource.createResource(doc.resource.toResource());
    return ServerResponse(204);
  }

  Future<ServerResponse> addToMany(
      String type, String id, String relationship, String body) async {
    final rel = Relationship.fromJson(json.decode(body));
    if (rel is ToMany) {
      await resource.addToMany(
          Identifier(type, id), relationship, rel.identifiers);
      final res = await _resource(type, id);
      return ServerResponse.ok(ToMany(
          res.toMany[relationship]
              .map(IdentifierEnvelope.fromIdentifier)
              .toList(),
          self: Link(routing.relationship(res.type, res.id, relationship)),
          related: Link(routing.related(res.type, res.id, relationship))));
    }
    // TODO: Return a meaningful response
    return ServerResponse.notFound();
  }

  ResourceEnvelope _enclose(Resource r) {
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

  Future<Resource> _resource(String type, String id) =>
      resource.fetchResources([Identifier(type, id)]).first;
}
