import 'package:json_api/src/server/json_api_request.dart';

/// This is a controller consolidating all possible requests a JSON:API server
/// may handle.
abstract class Controller {
  /// Finds an returns a primary resource collection.
  /// See https://jsonapi.org/format/#fetching-resources
  Future<void> fetchCollection(FetchCollection request);

  /// Finds an returns a primary resource.
  /// See https://jsonapi.org/format/#fetching-resources
  Future<void> fetchResource(FetchResource request);

  /// Finds an returns a related resource or a collection of related resources.
  /// See https://jsonapi.org/format/#fetching-resources
  Future<void> fetchRelated(FetchRelated request);

  /// Finds an returns a relationship of a primary resource.
  /// See https://jsonapi.org/format/#fetching-relationships
  Future<void> fetchRelationship(FetchRelationship request);

  /// Deletes the resource.
  /// See https://jsonapi.org/format/#crud-deleting
  Future<void> deleteResource(DeleteResource request);

  /// Creates a new resource in the collection.
  /// See https://jsonapi.org/format/#crud-creating
  Future<void> createResource(CreateResource request);

  /// Updates the resource.
  /// See https://jsonapi.org/format/#crud-updating
  Future<void> updateResource(UpdateResource request);

  /// Replaces the to-one relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-one-relationships
  Future<void> replaceToOne(ReplaceToOne request);

  /// Replaces the to-many relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<void> replaceToMany(ReplaceToMany request);

  /// Removes the given identifiers from the to-many relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<void> deleteFromRelationship(DeleteFromRelationship request);

  /// Adds the given identifiers to  the to-many relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<void> addToRelationship(AddToRelationship request);
}
