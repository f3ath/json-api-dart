import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:json_api/src/document.dart';
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
    return route.call(this, request);
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
    try {
      final res = await _resource(type, id);
      return ServerResponse.ok(
          ResourceDocument(nullable(ResourceObject.fromResource)(res)));
    } on ResourceControllerException catch (e) {
      return ServerResponse(e.httpStatus,
          ErrorDocument([ErrorObject.fromResourceControllerException(e)]));
    }
  }

  Future<ServerResponse> fetchRelated(String type, String id,
      String relationship, JsonApiHttpRequest request) async {
    try {
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
    } on ResourceControllerException catch (e) {
      return ServerResponse(e.httpStatus,
          ErrorDocument([ErrorObject.fromResourceControllerException(e)]));
    }
  }

  Future<ServerResponse> fetchRelationship(String type, String id,
      String relationship, JsonApiHttpRequest request) async {
    try {
      final res = await _resource(type, id);
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
    } on ResourceControllerException catch (e) {
      return ServerResponse(e.httpStatus,
          ErrorDocument([ErrorObject.fromResourceControllerException(e)]));
    }
  }

  Future<ServerResponse> createResource(
      String type, JsonApiHttpRequest request) async {
    try {
      final requestedResource =
          ResourceDocument.fromJson(json.decode(await request.body()))
              .resourceObject
              .toResource();
      final createdResource =
          await controller.createResource(type, requestedResource, request);

      if (requestedResource.hasId) {
        return ServerResponse.noContent();
      } else {
        return ServerResponse.created(
            ResourceDocument(ResourceObject.fromResource(createdResource)))
          ..headers['Location'] = router
              .resource(createdResource.type, createdResource.id)
              .toString();
      }
    } on ResourceControllerException catch (e) {
      return ServerResponse(e.httpStatus,
          ErrorDocument([ErrorObject.fromResourceControllerException(e)]));
    }
  }

  Future<ServerResponse> deleteResource(
      String type, String id, JsonApiHttpRequest request) async {
    try {
      final meta = await controller.deleteResource(type, id, request);
      if (meta?.isNotEmpty == true) {
        return ServerResponse.ok(MetaDocument(meta));
      } else {
        return ServerResponse.noContent();
      }
    } on ResourceControllerException catch (e) {
      return ServerResponse(e.httpStatus,
          ErrorDocument([ErrorObject.fromResourceControllerException(e)]));
    }
  }

  Future<Resource> _resource(String type, String id) =>
      controller.fetchResources([Identifier(type, id)]).first;
}
