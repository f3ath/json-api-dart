import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/src/server/http_response_factory.dart';

abstract class JsonApiResponse {
  HttpResponse httpResponse(HttpResponseFactory response);
}

class NoContentResponse implements JsonApiResponse {
  @override
  HttpResponse httpResponse(HttpResponseFactory response) =>
      response.noContent();
}

class CollectionResponse implements JsonApiResponse {
  final Iterable<Resource> collection;
  final Iterable<Resource> included;
  final int total;

  CollectionResponse(this.collection, {this.included, this.total});

  @override
  HttpResponse httpResponse(HttpResponseFactory response) =>
      response.collection(collection, included: included, total: total);
}

class AcceptedResponse implements JsonApiResponse {
  final Resource resource;

  AcceptedResponse(this.resource);

  @override
  HttpResponse httpResponse(HttpResponseFactory response) =>
      response.accepted(resource);
}

class ErrorResponse implements JsonApiResponse {
  final Iterable<ErrorObject> errors;
  final int statusCode;

  ErrorResponse(this.statusCode, this.errors);

  static JsonApiResponse badRequest(Iterable<ErrorObject> errors) =>
      ErrorResponse(400, errors);

  static JsonApiResponse forbidden(Iterable<ErrorObject> errors) =>
      ErrorResponse(403, errors);

  static JsonApiResponse notFound(Iterable<ErrorObject> errors) =>
      ErrorResponse(404, errors);

  /// The allowed methods can be specified in [allow]
  static JsonApiResponse methodNotAllowed(
          Iterable<ErrorObject> errors, Iterable<String> allow) =>
      ErrorResponse(405, errors).._headers['Allow'] = allow.join(', ');

  static JsonApiResponse conflict(Iterable<ErrorObject> errors) =>
      ErrorResponse(409, errors);

  static JsonApiResponse notImplemented(Iterable<ErrorObject> errors) =>
      ErrorResponse(501, errors);

  @override
  HttpResponse httpResponse(HttpResponseFactory response) =>
      response.error(errors, statusCode, _headers);

  final _headers = <String, String>{};
}

class MetaResponse implements JsonApiResponse {
  final Map<String, Object> meta;

  MetaResponse(this.meta);

  @override
  HttpResponse httpResponse(HttpResponseFactory response) =>
      response.meta(meta);
}

class ResourceResponse implements JsonApiResponse {
  final Resource resource;
  final Iterable<Resource> included;

  ResourceResponse(this.resource, {this.included});

  @override
  HttpResponse httpResponse(HttpResponseFactory response) =>
      response.resource(resource, included: included);
}

class ResourceCreatedResponse implements JsonApiResponse {
  final Resource resource;

  ResourceCreatedResponse(this.resource);

  @override
  HttpResponse httpResponse(HttpResponseFactory response) =>
      response.resourceCreated(resource);
}

class SeeOtherResponse implements JsonApiResponse {
  final String type;
  final String id;

  SeeOtherResponse(this.type, this.id);

  @override
  HttpResponse httpResponse(HttpResponseFactory response) =>
      response.seeOther(type, id);
}

class ToManyResponse implements JsonApiResponse {
  final Iterable<Identifiers> collection;
  final String type;
  final String id;
  final String relationship;

  ToManyResponse(this.type, this.id, this.relationship, this.collection);

  @override
  HttpResponse httpResponse(HttpResponseFactory response) =>
      response.toMany(collection, type, id, relationship);
}

class ToOneResponse implements JsonApiResponse {
  final String type;
  final String id;
  final String relationship;
  final Identifiers identifier;

  ToOneResponse(this.type, this.id, this.relationship, this.identifier);

  @override
  HttpResponse httpResponse(HttpResponseFactory response) =>
      response.toOneDocument(identifier, type, id, relationship);
}
