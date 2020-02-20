import 'package:json_api/document.dart';
import 'package:json_api/src/server/response_converter.dart';

/// the base interface for all JSON:API responses
abstract class Response {
  /// Converts the JSON:API response to another object, e.g. HTTP response.
  T convert<T>(ResponseConverter<T> converter);
}

class NoContentResponse implements Response {
  @override
  T convert<T>(ResponseConverter<T> converter) => converter.noContent();
}

class CollectionResponse implements Response {
  final Iterable<Resource> collection;
  final Iterable<Resource> included;
  final int total;

  CollectionResponse(this.collection, {this.included, this.total});

  @override
  T convert<T>(ResponseConverter<T> converter) =>
      converter.collection(collection, included: included, total: total);
}

class AcceptedResponse implements Response {
  final Resource resource;

  AcceptedResponse(this.resource);

  @override
  T convert<T>(ResponseConverter<T> converter) => converter.accepted(resource);
}

class ErrorResponse implements Response {
  final Iterable<ErrorObject> errors;
  final int statusCode;

  ErrorResponse(this.statusCode, this.errors);

  static Response badRequest(Iterable<ErrorObject> errors) =>
      ErrorResponse(400, errors);

  static Response forbidden(Iterable<ErrorObject> errors) =>
      ErrorResponse(403, errors);

  static Response notFound(Iterable<ErrorObject> errors) =>
      ErrorResponse(404, errors);

  /// The allowed methods can be specified in [allow]
  static Response methodNotAllowed(
          Iterable<ErrorObject> errors, Iterable<String> allow) =>
      ErrorResponse(405, errors).._headers['Allow'] = allow.join(', ');

  static Response conflict(Iterable<ErrorObject> errors) =>
      ErrorResponse(409, errors);

  static Response notImplemented(Iterable<ErrorObject> errors) =>
      ErrorResponse(501, errors);

  @override
  T convert<T>(ResponseConverter<T> converter) =>
      converter.error(errors, statusCode, _headers);

  final _headers = <String, String>{};
}

class MetaResponse implements Response {
  final Map<String, Object> meta;

  MetaResponse(this.meta);

  @override
  T convert<T>(ResponseConverter<T> converter) => converter.meta(meta);
}

class ResourceResponse implements Response {
  final Resource resource;
  final Iterable<Resource> included;

  ResourceResponse(this.resource, {this.included});

  @override
  T convert<T>(ResponseConverter<T> converter) =>
      converter.resource(resource, included: included);
}

class ResourceCreatedResponse implements Response {
  final Resource resource;

  ResourceCreatedResponse(this.resource);

  @override
  T convert<T>(ResponseConverter<T> converter) =>
      converter.resourceCreated(resource);
}

class SeeOtherResponse implements Response {
  final String type;
  final String id;

  SeeOtherResponse(this.type, this.id);

  @override
  T convert<T>(ResponseConverter<T> converter) => converter.seeOther(type, id);
}

class ToManyResponse implements Response {
  final Iterable<Identifier> collection;
  final String type;
  final String id;
  final String relationship;

  ToManyResponse(this.type, this.id, this.relationship, this.collection);

  @override
  T convert<T>(ResponseConverter<T> converter) =>
      converter.toMany(type, id, relationship, collection);
}

class ToOneResponse implements Response {
  final String type;
  final String id;
  final String relationship;
  final Identifier identifier;

  ToOneResponse(this.type, this.id, this.relationship, this.identifier);

  @override
  T convert<T>(ResponseConverter<T> converter) =>
      converter.toOne(identifier, type, id, relationship);
}
