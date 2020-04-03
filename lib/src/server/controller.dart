import 'package:json_api/document.dart';
import 'package:json_api/src/document/error_object.dart';
import 'package:json_api/src/server/repository.dart';

/// This is a controller consolidating all possible requests a JSON:API server
/// may handle.
abstract class Controller {
  /// Finds an returns a primary resource collection.
  /// See https://jsonapi.org/format/#fetching-resources
  Future<void> fetchCollection(CollectionRequest request);

  /// Finds an returns a primary resource.
  /// See https://jsonapi.org/format/#fetching-resources
  Future<void> fetchResource(ResourceRequest request);

  /// Finds an returns a related resource or a collection of related resources.
  /// See https://jsonapi.org/format/#fetching-resources
  Future<void> fetchRelated(RelatedRequest request);

  /// Finds an returns a relationship of a primary resource.
  /// See https://jsonapi.org/format/#fetching-relationships
  Future<void> fetchRelationship(RelationshipRequest request);

  /// Deletes the resource.
  /// See https://jsonapi.org/format/#crud-deleting
  Future<void> deleteResource(ResourceRequest request);

  /// Creates a new resource in the collection.
  /// See https://jsonapi.org/format/#crud-creating
  Future<void> createResource(CollectionRequest request, Resource resource);

  /// Updates the resource.
  /// See https://jsonapi.org/format/#crud-updating
  Future<void> updateResource(ResourceRequest request, Resource resource);

  /// Replaces the to-one relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-one-relationships
  Future<void> replaceToOne(RelationshipRequest request, Identifier identifier);

  /// Replaces the to-many relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<void> replaceToMany(
      RelationshipRequest request, Iterable<Identifier> identifiers);

  /// Removes the given identifiers from the to-many relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<void> deleteFromRelationship(
      RelationshipRequest request, Iterable<Identifier> identifiers);

  /// Adds the given identifiers to  the to-many relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<void> addToRelationship(
      RelationshipRequest request, Iterable<Identifier> identifiers);
}

abstract class ControllerRequest {
  Map<String, List<String>> get queryParameters;

  /// HTTP 404 Not Found response.
  ///
  /// See:
  /// - https://jsonapi.org/format/#fetching-resources-responses-404
  /// - https://jsonapi.org/format/#fetching-relationships-responses-404
  /// - https://jsonapi.org/format/#crud-creating-responses-404
  /// - https://jsonapi.org/format/#crud-updating-responses-404
  /// - https://jsonapi.org/format/#crud-deleting-responses-404
  void sendErrorNotFound(Iterable<ErrorObject> list);

  /// HTTP 403 Forbidden response.
  ///
  /// See:
  /// - https://jsonapi.org/format/#crud-creating-client-ids
  /// - https://jsonapi.org/format/#crud-creating-responses-403
  /// - https://jsonapi.org/format/#crud-updating-resource-relationships
  /// - https://jsonapi.org/format/#crud-updating-relationship-responses-403
  void sendErrorForbidden(Iterable<ErrorObject> list);

  /// HTTP 409 Conflict response.
  ///
  /// See:
  /// - https://jsonapi.org/format/#crud-creating-responses-409
  /// - https://jsonapi.org/format/#crud-updating-responses-409
  void sendErrorConflict(Iterable<ErrorObject> list);

  /// HTTP 400 Bad Request response.
  ///
  /// See:
  /// - https://jsonapi.org/format/#fetching-includes
  /// - https://jsonapi.org/format/#fetching-sorting
  /// - https://jsonapi.org/format/#query-parameters
  void sendErrorBadRequest(List<ErrorObject> list);

  /// HTTP 204 No Content response.
  ///
  /// See:
  /// - https://jsonapi.org/format/#crud-creating-responses-204
  /// - https://jsonapi.org/format/#crud-updating-responses-204
  /// - https://jsonapi.org/format/#crud-updating-relationship-responses-204
  /// - https://jsonapi.org/format/#crud-deleting-responses-204
  void sendNoContent();

  /// HTTP 202 Accepted response.
  ///
  /// See: https://jsonapi.org/recommendations/#asynchronous-processing
  void sendAccepted();

  /// HTTP 200 OK response containing an empty document.
  ///
  /// See:
  /// - https://jsonapi.org/format/#crud-updating-responses-200
  /// - https://jsonapi.org/format/#crud-updating-relationship-responses-200
  /// - https://jsonapi.org/format/#crud-deleting-responses-200
  void sendMeta();

  /// HTTP 303 See Other response.
  ///
  /// See: https://jsonapi.org/recommendations/#asynchronous-processing
  void sendSeeOther(String type, String id);
}

abstract class CollectionRequest implements ControllerRequest {
  String get type;

  /// HTTP 200 OK response with a resource collection.
  ///
  /// See: https://jsonapi.org/format/#fetching-resources-responses-200
  void sendCollection(Collection<Resource> c, {Iterable<Resource> include});

  /// HTTP 201 Created response containing a newly created resource
  ///
  /// See: https://jsonapi.org/format/#crud-creating-responses-201
  void sendCreatedResource(Resource modified);
}

abstract class ResourceRequest implements ControllerRequest {
  String get type;

  String get id;

  /// A successful response containing a resource object.
  ///
  /// See:
  /// - https://jsonapi.org/format/#fetching-resources-responses-200
  /// - https://jsonapi.org/format/#crud-updating-responses-200
  void sendResource(Resource resource, {Iterable<Resource> include});
}

abstract class RelationshipRequest implements ControllerRequest {
  String get type;

  String get id;

  String get relationship;

  /// HTTP 200 OK response containing a to-may relationship.
  ///
  /// See:
  /// - https://jsonapi.org/format/#fetching-relationships-responses-200
  /// - https://jsonapi.org/format/#crud-updating-relationship-responses-200
  void sendToManyRelationship(Iterable<Identifier> many,
      {Iterable<Resource> include});

  /// HTTP 200 OK response containing a to-one relationship
  ///
  /// See:
  /// - https://jsonapi.org/format/#fetching-relationships-responses-200
  /// - https://jsonapi.org/format/#crud-updating-relationship-responses-200
  void sendToOneRelationship(Identifier one, {Iterable<Resource> include});
}

abstract class RelatedRequest implements ControllerRequest {
  String get type;

  String get id;

  String get relationship;

  /// A successful response containing a resource object.
  ///
  /// See:
  /// - https://jsonapi.org/format/#fetching-resources-responses-200
  /// - https://jsonapi.org/format/#crud-updating-responses-200
  void sendResource(Resource resource, {Iterable<Resource> include});

  /// HTTP 200 OK response with a resource collection.
  ///
  /// See: https://jsonapi.org/format/#fetching-resources-responses-200
  void sendCollection(Collection<Resource> collection,
      {Iterable<Resource> include});
}
