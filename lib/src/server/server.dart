import 'dart:async';
import 'dart:convert';

import 'package:json_api/src/document/collection_document.dart';
import 'package:json_api/src/document/error_document.dart';
import 'package:json_api/src/document/error_object.dart';
import 'package:json_api/src/document/identifier_object.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource_document.dart';
import 'package:json_api/src/document/resource_object.dart';
import 'package:json_api/src/identifier.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/resource.dart';
import 'package:json_api/src/server/json_api_controller.dart';
import 'package:json_api/src/server/request.dart';
import 'package:json_api/src/server/resource_controller.dart';
import 'package:json_api/src/server/response.dart';
import 'package:json_api/src/server/routing.dart';

class JsonApiServer implements JsonApiController {
  final ResourceController controller;
  final Routing routing;

  JsonApiServer(this.controller, this.routing);

  Future<ServerResponse> handle(String method, Uri uri, String body) async {
    final jsonApiRequest = await routing.resolve(method, uri, body);
    if (jsonApiRequest == null) {
      return ServerResponse.notFound(
          ErrorDocument([ErrorObject(status: '404', detail: 'Unknown route')]));
    }
    if (!controller.supports(jsonApiRequest.type)) {
      return ServerResponse.notFound(ErrorDocument(
          [ErrorObject(status: '404', detail: 'Unknown resource type')]));
    }
    return jsonApiRequest.fulfill(this);
  }

  Future<ServerResponse> fetchCollection(CollectionRequest rq) async {
    final collection = await controller.fetchCollection(rq.type, rq.params);

    final pagination = Pagination.fromMap(collection.page.mapPages(
        (_) => Link(routing.collection(rq.type, params: _?.parameters))));

    final doc = CollectionDocument(
        collection.elements.map(ResourceObject.fromResource),
        self: Link(
            routing.collection(rq.type, params: collection.page?.parameters)),
        pagination: pagination);
    return ServerResponse.ok(doc);
  }

  Future<ServerResponse> fetchResource(ResourceRequest rq) async {
    try {
      final res = await _resource(rq.type, rq.id);
      return ServerResponse.ok(
          ResourceDocument(nullable(ResourceObject.fromResource)(res)));
    } on ResourceControllerException catch (e) {
      return ServerResponse(e.httpStatus,
          ErrorDocument([ErrorObject.fromResourceControllerException(e)]));
    }
  }

  Future<ServerResponse> fetchRelated(RelatedRequest rq) async {
    try {
      final res =
          await controller.fetchResources([Identifier(rq.type, rq.id)]).first;

      if (res.toOne.containsKey(rq.relationship)) {
        final id = res.toOne[rq.relationship];
        // TODO check if id == null
        final related = await controller.fetchResources([id]).first;
        return ServerResponse.ok(
            ResourceDocument(ResourceObject.fromResource(related)));
      }

      if (res.toMany.containsKey(rq.relationship)) {
        final ids = res.toMany[rq.relationship];
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

  Future<ServerResponse> fetchRelationship(RelationshipRequest rq) async {
    try {
      final res = await _resource(rq.type, rq.id);
      if (res.toOne.containsKey(rq.relationship)) {
        return ServerResponse.ok(ToOne(
            nullable(IdentifierObject.fromIdentifier)(
                res.toOne[rq.relationship]),
            self: Link(routing.relationship(res.type, res.id, rq.relationship)),
            related: Link(routing.related(res.type, res.id, rq.relationship))));
      }
      if (res.toMany.containsKey(rq.relationship)) {
        return ServerResponse.ok(ToMany(
            res.toMany[rq.relationship].map(IdentifierObject.fromIdentifier),
            self: Link(routing.relationship(res.type, res.id, rq.relationship)),
            related: Link(routing.related(res.type, res.id, rq.relationship))));
      }
      return ServerResponse(404);
    } on ResourceControllerException catch (e) {
      return ServerResponse(e.httpStatus,
          ErrorDocument([ErrorObject.fromResourceControllerException(e)]));
    }
  }

  Future<ServerResponse> createResource(CollectionRequest rq) async {
    try {
      final requestedResource = ResourceDocument.fromJson(json.decode(rq.body))
          .resourceObject
          .toResource();
      final createdResource = await controller.createResource(
          rq.type, requestedResource, rq.params);

      if (requestedResource.hasId) {
        return ServerResponse.noContent();
      } else {
        return ServerResponse.created(
            ResourceDocument(ResourceObject.fromResource(createdResource)))
          ..headers['Location'] = routing
              .resource(createdResource.type, createdResource.id)
              .toString();
      }
    } on ResourceControllerException catch (e) {
      return ServerResponse(e.httpStatus,
          ErrorDocument([ErrorObject.fromResourceControllerException(e)]));
    }
  }

//  Future<ServerResponse> updateResource(
//      String type, String id, String body) async {
//    // TODO: check that [type] matcher [resource.type]
//    final doc = ResourceDocument.fromJson(json.decode(body));
//    await controller.updateResource(
//        Identifier(type, id), doc.resourceEnvelope.toResource());
//    return ServerResponse(204);
//  }
//
//  Future<ServerResponse> addToMany(
//      String type, String id, String relationship, String body) async {
//    final rel = Relationship.fromJson(json.decode(body));
//    if (rel is ToMany) {
//      await controller.addToMany(
//          Identifier(type, id), relationship, rel.identifiers);
//      final res = await _resource(type, id);
//      return ServerResponse.ok(ToMany(
//          res.toMany[relationship]
//              .map(IdentifierEnvelope.fromIdentifier)
//              .toList(),
//          self: Link(routing.relationship(res.type, res.id, relationship)),
//          related: Link(routing.related(res.type, res.id, relationship))));
//    }
//    // TODO: Return a meaningful response
//    return ServerResponse.notFound();
//  }

  Future<Resource> _resource(String type, String id) =>
      controller.fetchResources([Identifier(type, id)]).first;
}
