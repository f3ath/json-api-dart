import 'package:json_api/document.dart';
import 'package:json_api/src/server/http_response_builder.dart';

abstract class JsonApiResponse {
  void build(HttpResponseBuilder response);
}

class NoContentResponse implements JsonApiResponse {
  @override
  void build(HttpResponseBuilder response) {
    response.statusCode = 204;
  }
}

class CollectionResponse implements JsonApiResponse {
  final Iterable<Resource> collection;
  final Iterable<Resource> included;
  final int total;

  CollectionResponse(this.collection, {this.included, this.total});

  @override
  void build(HttpResponseBuilder response) {
    response.collectionDocument(collection, included: included, total: total);
  }
}

class AcceptedResponse implements JsonApiResponse {
  final Resource resource;

  AcceptedResponse(this.resource);

  @override
  void build(HttpResponseBuilder response) {
    response
      ..statusCode = 202
      ..addContentLocation(resource.type, resource.id)
      ..resourceDocument(resource);
  }
}

class ErrorResponse implements JsonApiResponse {
  final Iterable<JsonApiError> errors;
  final int statusCode;

  ErrorResponse(this.statusCode, this.errors);

  static JsonApiResponse badRequest(Iterable<JsonApiError> errors) =>
      ErrorResponse(400, errors);

  static JsonApiResponse forbidden(Iterable<JsonApiError> errors) =>
      ErrorResponse(403, errors);

  static JsonApiResponse notFound(Iterable<JsonApiError> errors) =>
      ErrorResponse(404, errors);

  /// The allowed methods can be specified in [allow]
  static JsonApiResponse methodNotAllowed(Iterable<JsonApiError> errors,
          {Iterable<String> allow}) =>
      ErrorResponse(405, errors).._headers['Allow'] = allow.join(', ');

  static JsonApiResponse conflict(Iterable<JsonApiError> errors) =>
      ErrorResponse(409, errors);

  static JsonApiResponse notImplemented(Iterable<JsonApiError> errors) =>
      ErrorResponse(501, errors);

  @override
  void build(HttpResponseBuilder response) {
    response
      ..statusCode = statusCode
      ..addHeaders(_headers)
      ..errorDocument(errors);
  }

  final _headers = <String, String>{};
}

class MetaResponse implements JsonApiResponse {
  final Map<String, Object> meta;

  MetaResponse(this.meta);

  @override
  void build(HttpResponseBuilder response) {
    response.metaDocument(meta);
  }
}

class ResourceResponse implements JsonApiResponse {
  final Resource resource;
  final Iterable<Resource> included;

  ResourceResponse(this.resource, {this.included});

  @override
  void build(HttpResponseBuilder response) {
    response.resourceDocument(resource, included: included);
  }
}

class ResourceCreatedResponse implements JsonApiResponse {
  final Resource resource;

  ResourceCreatedResponse(this.resource);

  @override
  void build(HttpResponseBuilder response) {
    response
      ..statusCode = 201
      ..addLocation(resource.type, resource.id)
      ..createdResourceDocument(resource);
  }
}

class SeeOtherResponse implements JsonApiResponse {
  final String type;
  final String id;

  SeeOtherResponse(this.type, this.id);

  @override
  void build(HttpResponseBuilder response) {
    response
      ..statusCode = 303
      ..addLocation(type, id);
  }
}

class ToManyResponse implements JsonApiResponse {
  final Iterable<Identifiers> collection;
  final String type;
  final String id;
  final String relationship;

  ToManyResponse(this.type, this.id, this.relationship, this.collection);

  @override
  void build(HttpResponseBuilder response) {
    response.toManyDocument(collection, type, id, relationship);
  }
}

class ToOneResponse implements JsonApiResponse {
  final String type;
  final String id;
  final String relationship;
  final Identifiers identifier;

  ToOneResponse(this.type, this.id, this.relationship, this.identifier);

  @override
  void build(HttpResponseBuilder response) {
    response.toOneDocument(identifier, type, id, relationship);
  }
}
