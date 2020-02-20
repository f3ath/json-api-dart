import 'package:json_api/document.dart';
import 'package:json_api/src/server/pagination.dart';

/// Converts JsonApi Controller responses to other responses, e.g. HTTP
abstract class ResponseConverter<T> {
  /// A document containing a list of errors
  T error(Iterable<ErrorObject> errors, int statusCode,
      Map<String, String> headers);

  /// A document containing a collection of resources
  T collection(Iterable<Resource> collection,
      {int total, Iterable<Resource> included, Pagination pagination});

  /// HTTP 202 Accepted response
  T accepted(Resource resource);

  /// HTTP 200 with a document containing just a meta member
  T meta(Map<String, Object> meta);

  /// HTTP 200 with a document containing a single resource
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

  /// HTTP 303 See Other response with the Location header pointing
  /// to another resource
  T seeOther(String type, String id);

  /// HTTP 200 with a document containing a to-many relationship
  T toMany(String type, String id, String relationship,
      Iterable<Identifier> identifiers,
      {Iterable<Resource> included});

  /// HTTP 200 with a document containing a to-one relationship
  T toOne(Identifier identifier, String type, String id, String relationship,
      {Iterable<Resource> included});

  /// The HTTP 204 No Content response
  T noContent();
}
