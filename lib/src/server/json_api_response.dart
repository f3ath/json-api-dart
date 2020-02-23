import 'package:json_api/document.dart';
import 'package:json_api/src/server/relationship_target.dart';
import 'package:json_api/src/server/resource_target.dart';
import 'package:json_api/src/server/response_converter.dart';

/// The base interface for JSON:API responses.
abstract class JsonApiResponse {
  /// Converts the JSON:API response to another object, e.g. HTTP response.
  T convert<T>(ResponseConverter<T> converter);
}

/// HTTP 204 No Content response.
///
/// See:
/// - https://jsonapi.org/format/#crud-creating-responses-204
/// - https://jsonapi.org/format/#crud-updating-responses-204
/// - https://jsonapi.org/format/#crud-updating-relationship-responses-204
/// - https://jsonapi.org/format/#crud-deleting-responses-204
class NoContentResponse implements JsonApiResponse {
  @override
  T convert<T>(ResponseConverter<T> converter) => converter.noContent();
}

/// HTTP 200 OK response with a resource collection.
///
/// See: https://jsonapi.org/format/#fetching-resources-responses-200
class CollectionResponse implements JsonApiResponse {
  CollectionResponse(Iterable<Resource> resources,
      {Iterable<Resource> included, this.total})
      : resources = List.unmodifiable(resources),
        included = included == null ? null : List.unmodifiable(included);

  final List<Resource> resources;
  final List<Resource> included;

  final int total;

  @override
  T convert<T>(ResponseConverter<T> converter) =>
      converter.collection(resources, included: included, total: total);
}

/// HTTP 202 Accepted response.
///
/// See: https://jsonapi.org/recommendations/#asynchronous-processing
class AcceptedResponse implements JsonApiResponse {
  AcceptedResponse(this.resource);

  final Resource resource;

  @override
  T convert<T>(ResponseConverter<T> converter) => converter.accepted(resource);
}

/// A common error response.
///
/// See: https://jsonapi.org/format/#errors
class ErrorResponse implements JsonApiResponse {
  ErrorResponse(this.statusCode, Iterable<ErrorObject> errors,
      {Map<String, String> headers = const {}})
      : _headers = Map.unmodifiable(headers),
        errors = List.unmodifiable(errors);

  /// HTTP 400 Bad Request response.
  ///
  /// See:
  /// - https://jsonapi.org/format/#fetching-includes
  /// - https://jsonapi.org/format/#fetching-sorting
  /// - https://jsonapi.org/format/#query-parameters
  ErrorResponse.badRequest(Iterable<ErrorObject> errors) : this(400, errors);

  /// HTTP 403 Forbidden response.
  ///
  /// See:
  /// - https://jsonapi.org/format/#crud-creating-client-ids
  /// - https://jsonapi.org/format/#crud-creating-responses-403
  /// - https://jsonapi.org/format/#crud-updating-resource-relationships
  /// - https://jsonapi.org/format/#crud-updating-relationship-responses-403
  ErrorResponse.forbidden(Iterable<ErrorObject> errors) : this(403, errors);

  /// HTTP 404 Not Found response.
  ///
  /// See:
  /// - https://jsonapi.org/format/#fetching-resources-responses-404
  /// - https://jsonapi.org/format/#fetching-relationships-responses-404
  /// - https://jsonapi.org/format/#crud-creating-responses-404
  /// - https://jsonapi.org/format/#crud-updating-responses-404
  /// - https://jsonapi.org/format/#crud-deleting-responses-404
  ErrorResponse.notFound(Iterable<ErrorObject> errors) : this(404, errors);

  /// HTTP 405 Method Not Allowed response.
  /// The allowed methods can be specified in [allow]
  ErrorResponse.methodNotAllowed(
      Iterable<ErrorObject> errors, Iterable<String> allow)
      : this(405, errors, headers: {'Allow': allow.join(', ')});

  /// HTTP 409 Conflict response.
  ///
  /// See:
  /// - https://jsonapi.org/format/#crud-creating-responses-409
  /// - https://jsonapi.org/format/#crud-updating-responses-409
  ErrorResponse.conflict(Iterable<ErrorObject> errors) : this(409, errors);

  /// HTTP 500 Internal Server Error response.
  ErrorResponse.internalServerError(Iterable<ErrorObject> errors)
      : this(500, errors);

  /// HTTP 501 Not Implemented response.
  ErrorResponse.notImplemented(Iterable<ErrorObject> errors)
      : this(501, errors);

  /// Error objects to send with the response
  final List<ErrorObject> errors;

  /// HTTP status code
  final int statusCode;
  final Map<String, String> _headers;

  @override
  T convert<T>(ResponseConverter<T> converter) =>
      converter.error(errors, statusCode, _headers);
}

/// HTTP 200 OK response containing an empty document.
///
/// See:
/// - https://jsonapi.org/format/#crud-updating-responses-200
/// - https://jsonapi.org/format/#crud-updating-relationship-responses-200
/// - https://jsonapi.org/format/#crud-deleting-responses-200
class MetaResponse implements JsonApiResponse {
  MetaResponse(Map<String, Object> meta) : meta = Map.unmodifiable(meta);

  final Map<String, Object> meta;

  @override
  T convert<T>(ResponseConverter<T> converter) => converter.meta(meta);
}

/// A successful response containing a resource object.
///
/// See:
/// - https://jsonapi.org/format/#fetching-resources-responses-200
/// - https://jsonapi.org/format/#crud-updating-responses-200
class ResourceResponse implements JsonApiResponse {
  ResourceResponse(this.resource, {Iterable<Resource> included})
      : included = included == null ? null : List.unmodifiable(included);

  final Resource resource;

  final List<Resource> included;

  @override
  T convert<T>(ResponseConverter<T> converter) =>
      converter.resource(resource, included: included);
}

/// HTTP 201 Created response containing a newly created resource
///
/// See: https://jsonapi.org/format/#crud-creating-responses-201
class ResourceCreatedResponse implements JsonApiResponse {
  ResourceCreatedResponse(this.resource);

  final Resource resource;

  @override
  T convert<T>(ResponseConverter<T> converter) =>
      converter.resourceCreated(resource);
}

/// HTTP 303 See Other response.
///
/// See: https://jsonapi.org/recommendations/#asynchronous-processing
class SeeOtherResponse implements JsonApiResponse {
  SeeOtherResponse(this.target);

  final ResourceTarget target;

  @override
  T convert<T>(ResponseConverter<T> converter) => converter.seeOther(target);
}

/// HTTP 200 OK response containing a to-may relationship.
///
/// See:
/// - https://jsonapi.org/format/#fetching-relationships-responses-200
/// - https://jsonapi.org/format/#crud-updating-relationship-responses-200
class ToManyResponse implements JsonApiResponse {
  ToManyResponse(this.target, Iterable<Identifier> identifiers)
      : identifiers =
            identifiers == null ? null : List.unmodifiable(identifiers);

  final RelationshipTarget target;
  final List<Identifier> identifiers;

  @override
  T convert<T>(ResponseConverter<T> converter) =>
      converter.toMany(target, identifiers);
}

/// HTTP 200 OK response containing a to-one relationship
///
/// See:
/// - https://jsonapi.org/format/#fetching-relationships-responses-200
/// - https://jsonapi.org/format/#crud-updating-relationship-responses-200
class ToOneResponse implements JsonApiResponse {
  ToOneResponse(this.target, this.identifier);

  final RelationshipTarget target;

  final Identifier identifier;

  @override
  T convert<T>(ResponseConverter<T> converter) =>
      converter.toOne(target, identifier);
}
