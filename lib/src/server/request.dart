import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:json_api/document.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/page.dart';
import 'package:json_api/src/server/route.dart';
import 'package:json_api/src/server/server.dart';

abstract class JsonApiRequest {
  final HttpRequest _request;
  JsonApiServer _server;

  JsonApiRequest(this._request);

  Map<String, String> get queryParameters =>
      _request.requestedUri.queryParameters;

  HttpResponse get _response => _request.response;

  Future<Object> get _body async =>
      json.decode(await _request.transform(utf8.decoder).join());

  Future call(JsonApiController controller);

  Future notFound([List<JsonApiError> errors = const []]) =>
      _server.error(_response, 404, errors);

  bind(JsonApiServer server) => _server = server;
}

class FetchCollection extends JsonApiRequest {
  final CollectionRoute route;

  FetchCollection(HttpRequest request, this.route) : super(request);

  Future call(JsonApiController controller) => controller.fetchCollection(this);

  Future collection(Iterable<Resource> resources, {Page page}) =>
      _server.collection(_response, route, resources, page: page);
}

class FetchRelated extends JsonApiRequest {
  final RelatedRoute route;

  FetchRelated(HttpRequest request, this.route) : super(request);

  Future call(JsonApiController controller) => controller.fetchRelated(this);

  Future collection(Iterable<Resource> collection) =>
      _server.relatedCollection(_response, route, collection);

  Future resource(Resource resource) =>
      _server.relatedResource(_response, route, resource);
}

class FetchRelationship extends JsonApiRequest {
  final RelationshipRoute route;

  FetchRelationship(HttpRequest request, this.route) : super(request);

  Future call(JsonApiController controller) =>
      controller.fetchRelationship(this);

  Future toMany(Iterable<Identifier> collection) =>
      _server.toMany(_response, route, collection);

  Future toOne(Identifier id) => _server.toOne(_response, route, id);
}

class ReplaceRelationship extends JsonApiRequest {
  final RelationshipRoute route;

  ReplaceRelationship(HttpRequest request, this.route) : super(request);

  Future<Relationship> relationshipData() async =>
      Relationship.parse(await _body);

  Future call(JsonApiController controller) =>
      controller.replaceRelationship(this);

  Future noContent() => _server.write(_response, 204);

  Future toMany(Iterable<Identifier> collection) =>
      _server.toMany(_response, route, collection);

  Future toOne(Identifier id) => _server.toOne(_response, route, id);
}

class AddToRelationship extends JsonApiRequest {
  final RelationshipRoute route;

  AddToRelationship(HttpRequest request, this.route) : super(request);

  Future<Iterable<Identifier>> identifiers() async =>
      ToMany.parse(await _body).identifiers;

  Future call(JsonApiController controller) =>
      controller.addToRelationship(this);

  Future toMany(Iterable<Identifier> collection) =>
      _server.toMany(_response, route, collection);
}

class FetchResource extends JsonApiRequest {
  final ResourceRoute route;

  FetchResource(HttpRequest request, this.route) : super(request);

  Future call(JsonApiController controller) => controller.fetchResource(this);

  Future resource(Resource resource) =>
      _server.resource(_response, route, resource);
}

class DeleteResource extends JsonApiRequest {
  final ResourceRoute route;

  DeleteResource(HttpRequest request, this.route) : super(request);

  Future call(JsonApiController controller) => controller.deleteResource(this);

  Future noContent() => _server.write(_response, 204);

  Future meta(Map<String, Object> meta) => _server.meta(_response, route, meta);
}

class CreateResource extends JsonApiRequest {
  final CollectionRoute route;

  CreateResource(HttpRequest request, this.route) : super(request);

  Future<Resource> resource() async {
    return ResourceData.parseDocument(await _body).resourceObject.toResource();
  }

  Future call(JsonApiController controller) => controller.createResource(this);

  Future created(Resource resource) =>
      _server.created(_response, route, resource);

  Future conflict(List<JsonApiError> errors) =>
      _server.error(_response, 409, errors);

  Future noContent() => _server.write(_response, 204);
}

class UpdateResource extends JsonApiRequest {
  final ResourceRoute route;

  UpdateResource(HttpRequest request, this.route) : super(request);

  Future<Resource> resource() async {
    return ResourceData.parseDocument(await _body).resourceObject.toResource();
  }

  Future call(JsonApiController controller) => controller.updateResource(this);

  Future updated(Resource resource) =>
      _server.resource(_response, route, resource);

  Future conflict(List<JsonApiError> errors) =>
      _server.error(_response, 409, errors);

  Future forbidden(List<JsonApiError> errors) =>
      _server.error(_response, 403, errors);

  Future noContent() => _server.write(_response, 204);
}
