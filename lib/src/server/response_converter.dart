import 'package:json_api/document.dart';
import 'package:json_api/src/server/pagination.dart';
import 'package:json_api/src/server/relationship_target.dart';
import 'package:json_api/src/server/resource_target.dart';

/// Converts JsonApi Controller responses to other responses, e.g. HTTP
abstract class ResponseConverter<T> {
  /// A common error response.
  ///
  /// See: https://jsonapi.org/format/#errors
  T error(Iterable<ErrorObject> errors, int statusCode,
      Map<String, String> headers);

  /// HTTP 200 OK response with a resource collection.
  ///
  /// See: https://jsonapi.org/format/#fetching-resources-responses-200
  T collection(Iterable<Resource> resources,
      {int total, Iterable<Resource> included, Pagination pagination});

  /// HTTP 202 Accepted response.
  ///
  /// See: https://jsonapi.org/recommendations/#asynchronous-processing
  T accepted(Resource resource);

  /// HTTP 200 OK response containing an empty document.
  ///
  /// See:
  /// - https://jsonapi.org/format/#crud-updating-responses-200
  /// - https://jsonapi.org/format/#crud-updating-relationship-responses-200
  /// - https://jsonapi.org/format/#crud-deleting-responses-200
  T meta(Map<String, Object> meta);

  /// A successful response containing a resource object.
  ///
  /// See:
  /// - https://jsonapi.org/format/#fetching-resources-responses-200
  /// - https://jsonapi.org/format/#crud-updating-responses-200
  T resource(Resource resource, {Iterable<Resource> included});

  /// HTTP 200 with a document containing a single (primary) resource which has been created
  /// on the server. The difference with [resource] is that this
  /// method generates the `self` link to match the `location` header.
  ///
  /// This is the quote from the documentation:
  /// > If the resource object returned by the response contains a self key
  /// > in its links member and a Location header is provided, the value of
  /// > the self member MUST match the value of the Location header.
  ///
  /// See https://jsonapi.org/format/#crud-creating-responses-201
  T resourceCreated(Resource resource);

  /// HTTP 303 See Other response.
  ///
  /// See: https://jsonapi.org/recommendations/#asynchronous-processing
  T seeOther(ResourceTarget target);

  /// HTTP 200 OK response containing a to-may relationship.
  ///
  /// See:
  /// - https://jsonapi.org/format/#fetching-relationships-responses-200
  /// - https://jsonapi.org/format/#crud-updating-relationship-responses-200
  T toMany(RelationshipTarget target, Iterable<Identifier> identifiers,
      {Iterable<Resource> included});

  /// HTTP 200 OK response containing a to-one relationship
  ///
  /// See:
  /// - https://jsonapi.org/format/#fetching-relationships-responses-200
  /// - https://jsonapi.org/format/#crud-updating-relationship-responses-200
  T toOne(RelationshipTarget target, Identifier identifier,
      {Iterable<Resource> included});

  /// HTTP 204 No Content response.
  ///
  /// See:
  /// - https://jsonapi.org/format/#crud-creating-responses-204
  /// - https://jsonapi.org/format/#crud-updating-responses-204
  /// - https://jsonapi.org/format/#crud-updating-relationship-responses-204
  /// - https://jsonapi.org/format/#crud-deleting-responses-204
  T noContent();
}
