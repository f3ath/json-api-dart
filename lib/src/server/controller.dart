import 'package:json_api/src/server/json_api_request.dart';

/// This is a controller consolidating all possible requests a JSON:API server
/// may handle.
abstract class Controller<T> {
  /// Finds an returns a primary resource collection.
  /// See https://jsonapi.org/format/#fetching-resources
  T fetchCollection(FetchCollection request);

  /// Finds an returns a primary resource.
  /// See https://jsonapi.org/format/#fetching-resources
  T fetchResource(FetchResource request);

  /// Finds an returns a related resource or a collection of related resources.
  /// See https://jsonapi.org/format/#fetching-resources
  T fetchRelated(FetchRelated request);

  /// Finds an returns a relationship of a primary resource.
  /// See https://jsonapi.org/format/#fetching-relationships
  T fetchRelationship(FetchRelationship request);

  /// Deletes the resource.
  /// See https://jsonapi.org/format/#crud-deleting
  T deleteResource(DeleteResource request);

  /// Creates a new resource in the collection.
  /// See https://jsonapi.org/format/#crud-creating
  T createResource(CreateResource request);

  /// Updates the resource.
  /// See https://jsonapi.org/format/#crud-updating
  T updateResource(UpdateResource request);

  /// Replaces the to-one relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-one-relationships
  T replaceToOne(ReplaceToOne request);

  /// Replaces the to-many relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  T replaceToMany(ReplaceToMany request);

  /// Removes the given identifiers from the to-many relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  T deleteFromRelationship(DeleteFromRelationship request);

  /// Adds the given identifiers to  the to-many relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  T addToRelationship(AddToRelationship request);
}
