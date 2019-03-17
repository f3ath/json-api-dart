import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:json_api/document.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/page.dart';
import 'package:json_api/src/server/route.dart';
import 'package:json_api/src/server/server.dart';

abstract class _BaseRequest implements JsonApiRequest {
  final HttpRequest request;
  JsonApiServer server;

  _BaseRequest(this.request);

  Map<String, String> get queryParameters =>
      request.requestedUri.queryParameters;

  HttpResponse get _response => request.response;

  Future<Object> get _body async =>
      json.decode(await request.transform(utf8.decoder).join());

  Future call(JsonApiController controller);

  Future errorNotFound([Iterable<JsonApiError> errors = const []]) =>
      server.error(_response, 404, errors);

  bind(JsonApiServer s) => server = s;
}

class FetchCollection extends _BaseRequest implements FetchCollectionRequest {
  final CollectionRoute route;

  FetchCollection(HttpRequest request, this.route) : super(request);

  Future call(JsonApiController controller) => controller.fetchCollection(this);

  Future sendCollection(Iterable<Resource> resources, {Page page}) =>
      server.collection(_response, route, resources, page: page);
}

class FetchRelated extends _BaseRequest implements FetchRelatedRequest {
  final RelatedRoute route;

  FetchRelated(HttpRequest request, this.route) : super(request);

  Future call(JsonApiController controller) => controller.fetchRelated(this);

  Future sendCollection(Iterable<Resource> collection) =>
      server.relatedCollection(_response, route, collection);

  Future sendResource(Resource resource) =>
      server.relatedResource(_response, route, resource);
}

class FetchRelationship extends _BaseRequest
    implements FetchRelationshipRequest {
  final RelationshipRoute route;

  FetchRelationship(HttpRequest request, this.route) : super(request);

  Future call(JsonApiController controller) =>
      controller.fetchRelationship(this);

  Future sendToMany(Iterable<Identifier> collection) =>
      server.toMany(_response, route, collection);

  Future sendToOne(Identifier id) => server.toOne(_response, route, id);
}

class ReplaceRelationship extends _BaseRequest
    implements ReplaceRelationshipRequest {
  final RelationshipRoute route;

  ReplaceRelationship(HttpRequest request, this.route) : super(request);

  Future<Relationship> getRelationship() async =>
      Relationship.parse(await _body);

  Future call(JsonApiController controller) =>
      controller.replaceRelationship(this);

  Future sendNoContent() => server.write(_response, 204);

  Future sendToMany(Iterable<Identifier> collection) =>
      server.toMany(_response, route, collection);

  Future sendToOne(Identifier id) => server.toOne(_response, route, id);
}

class AddToRelationship extends _BaseRequest
    implements AddToRelationshipRequest {
  final RelationshipRoute route;

  AddToRelationship(HttpRequest request, this.route) : super(request);

  Future<Iterable<Identifier>> getIdentifiers() async =>
      ToMany.parse(await _body).identifiers;

  Future call(JsonApiController controller) =>
      controller.addToRelationship(this);

  Future sendToMany(Iterable<Identifier> collection) =>
      server.toMany(_response, route, collection);
}

class FetchResource extends _BaseRequest implements FetchResourceRequest {
  final ResourceRoute route;

  FetchResource(HttpRequest request, this.route) : super(request);

  Future call(JsonApiController controller) => controller.fetchResource(this);

  Future sendResource(Resource resource, {Iterable<Resource> included}) =>
      server.resource(_response, route, resource, included: included);
}

class DeleteResource extends _BaseRequest implements DeleteResourceRequest {
  final ResourceRoute route;

  DeleteResource(HttpRequest request, this.route) : super(request);

  Future call(JsonApiController controller) => controller.deleteResource(this);

  Future sendNoContent() => server.write(_response, 204);

  Future sendMeta(Map<String, Object> meta) =>
      server.meta(_response, route, meta);
}

class CreateResource extends _BaseRequest implements CreateResourceRequest {
  final CollectionRoute route;

  CreateResource(HttpRequest request, this.route) : super(request);

  Future<Resource> getResource() async {
    return ResourceData.parse(await _body).resourceJson.toResource();
  }

  Future call(JsonApiController controller) => controller.createResource(this);

  Future sendCreated(Resource resource) =>
      server.created(_response, route, resource);

  Future errorConflict(Iterable<JsonApiError> errors) =>
      server.error(_response, 409, errors);

  Future sendNoContent() => server.write(_response, 204);
}

class UpdateResource extends _BaseRequest implements UpdateResourceRequest {
  final ResourceRoute route;

  UpdateResource(HttpRequest request, this.route) : super(request);

  Future<Resource> getResource() async {
    return ResourceData.parse(await _body).resourceJson.toResource();
  }

  Future call(JsonApiController controller) => controller.updateResource(this);

  Future sendUpdated(Resource resource) =>
      server.resource(_response, route, resource);

  Future errorConflict(Iterable<JsonApiError> errors) =>
      server.error(_response, 409, errors);

  Future errorForbidden(Iterable<JsonApiError> errors) =>
      server.error(_response, 403, errors);

  Future sendNoContent() => server.write(_response, 204);
}
