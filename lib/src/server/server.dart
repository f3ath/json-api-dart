import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:json_api/document.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/server/json_api_controller.dart';
import 'package:json_api/src/server/request.dart';
import 'package:json_api/src/server/resource_controller.dart';
import 'package:json_api/src/server/response.dart';
import 'package:json_api/src/server/router.dart';

class JsonApiServer implements JsonApiController {
  final ResourceController controller;
  final Router router;

  JsonApiServer(this.controller, this.router);

  Future<ServerResponse> handle(JsonApiHttpRequest request) async {
    final route = await router.resolve(request);
    if (route == null) {
      return ServerResponse.notFound(
          ErrorDocument([ErrorObject(status: '404', detail: 'Unknown route')]));
    }
    if (!controller.supports(route.type)) {
      return ServerResponse.notFound(ErrorDocument(
          [ErrorObject(status: '404', detail: 'Unknown resource type')]));
    }
    try {
      return await route.call(this, request);
    } on ResourceControllerException catch (e) {
      return ServerResponse(e.httpStatus,
          ErrorDocument([ErrorObject.fromResourceControllerException(e)]));
    }
  }

  Future<ServerResponse> fetchCollection(
      String type, JsonApiHttpRequest request) async {
    final collection = await controller.fetchCollection(type, request);

    final pagination = Pagination.fromMap(collection.page
        .mapPages((_) => Link(router.collection(type, params: _?.parameters))));

    final doc = CollectionDocument(
        collection.elements.map(ResourceObject.fromResource),
        self:
            Link(router.collection(type, params: collection.page?.parameters)),
        pagination: pagination);
    return ServerResponse.ok(doc);
  }

  Future<ServerResponse> fetchResource(
      String type, String id, JsonApiHttpRequest request) async {
    final res = await controller.fetchResources([Identifier(type, id)]).first;
    return ServerResponse.ok(
        ResourceDocument(nullable(ResourceObject.fromResource)(res)));
  }

  Future<ServerResponse> fetchRelated(String type, String id,
      String relationship, JsonApiHttpRequest request) async {
    final res = await controller.fetchResources([Identifier(type, id)]).first;

    if (res.toOne.containsKey(relationship)) {
      final id = res.toOne[relationship];
      // TODO check if id == null
      final related = await controller.fetchResources([id]).first;
      return ServerResponse.ok(
          ResourceDocument(ResourceObject.fromResource(related)));
    }

    if (res.toMany.containsKey(relationship)) {
      final ids = res.toMany[relationship];
      final related = await controller.fetchResources(ids).toList();
      return ServerResponse.ok(
          CollectionDocument(related.map(ResourceObject.fromResource)));
    }

    return ServerResponse(404);
  }

  Future<ServerResponse> fetchRelationship(String type, String id,
      String relationship, JsonApiHttpRequest request) async {
    final res = await controller.fetchResources([Identifier(type, id)]).first;
    if (res.toOne.containsKey(relationship)) {
      return ServerResponse.ok(ToOne(
          nullable(IdentifierObject.fromIdentifier)(res.toOne[relationship]),
          self: Link(router.relationship(res.type, res.id, relationship)),
          related: Link(router.related(res.type, res.id, relationship))));
    }
    if (res.toMany.containsKey(relationship)) {
      return ServerResponse.ok(ToMany(
          res.toMany[relationship].map(IdentifierObject.fromIdentifier),
          self: Link(router.relationship(res.type, res.id, relationship)),
          related: Link(router.related(res.type, res.id, relationship))));
    }
    return ServerResponse(404);
  }

  Future<ServerResponse> replaceRelationship(String type, String id,
      String relationship, JsonApiHttpRequest request) async {
    final rel = Relationship.fromJson(json.decode(await request.body()));
    if (rel is ToOne) {
      final response = await controller.replaceToOne(
          type, id, relationship, rel.toIdentifier(), request);
      if (response.isNoContent) {
        return ServerResponse.noContent();
      }
    }

    if (rel is ToMany) {
      final response = await controller.replaceToMany(
          type, id, relationship, rel.toIdentifiers(), request);
      if (response.isNoContent) {
        return ServerResponse.noContent();
      }
    }
  }

  @override
  Future<ServerResponse> addToMany(String type, String id, String relationship,
      JsonApiHttpRequest request) async {
    final rel = ToMany.fromJson(json.decode(await request.body()));
    final ids = await controller.addToMany(
        type, id, relationship, rel.toIdentifiers(), request);
    return ServerResponse.ok(ToMany(ids.map(IdentifierObject.fromIdentifier),
        self: Link(router.relationship(type, id, relationship)),
        related: Link(router.related(type, id, relationship))));
  }

  Future<ServerResponse> createResource(
      String type, JsonApiHttpRequest request) async {
    final requestedResource =
        ResourceDocument.fromJson(json.decode(await request.body()))
            .resourceObject
            .toResource();
    final createdResource =
        await controller.createResource(type, requestedResource, request);

    if (requestedResource.hasId) {
      return ServerResponse.noContent();
    }
    return ServerResponse.created(
        ResourceDocument(ResourceObject.fromResource(createdResource)))
      ..headers['Location'] =
          router.resource(createdResource.type, createdResource.id).toString();
  }

  Future<ServerResponse> deleteResource(
      String type, String id, JsonApiHttpRequest request) async {
    final meta = await controller.deleteResource(type, id, request);
    if (meta?.isNotEmpty == true) {
      return ServerResponse.ok(MetaDocument(meta));
    }
    return ServerResponse.noContent();
  }

  Future<ServerResponse> updateResource(
      String type, String id, JsonApiHttpRequest request) async {
    final resource =
        ResourceDocument.fromJson(json.decode(await request.body()))
            .resourceObject
            .toResource();
    final updated =
        await controller.updateResource(type, id, resource, request);
    if (updated == null) {
      return ServerResponse.noContent();
    }
    return ServerResponse.ok(
        ResourceDocument(ResourceObject.fromResource(updated)));
  }
}
