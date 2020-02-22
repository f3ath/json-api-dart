import 'package:json_api/document.dart';

/// This is a controller consolidating all possible requests a JSON:API server
/// may handle.
abstract class Controller<T> {
  /// Finds an returns a primary resource collection.
  /// See https://jsonapi.org/format/#fetching-resources
  T fetchCollection(String type, Map<String, List<String>> queryParameters);

  /// Finds an returns a primary resource.
  /// See https://jsonapi.org/format/#fetching-resources
  T fetchResource(
      String type, String id, Map<String, List<String>> queryParameters);

  /// Finds an returns a related resource or a collection of related resources.
  /// See https://jsonapi.org/format/#fetching-resources
  T fetchRelated(String type, String id, String relationship,
      Map<String, List<String>> queryParameters);

  /// Finds an returns a relationship of a primary resource.
  /// See https://jsonapi.org/format/#fetching-relationships
  T fetchRelationship(String type, String id, String relationship,
      Map<String, List<String>> queryParameters);

  /// Deletes the resource.
  /// See https://jsonapi.org/format/#crud-deleting
  T deleteResource(String type, String id);

  /// Creates a new resource in the collection.
  /// See https://jsonapi.org/format/#crud-creating
  T createResource(String type, Resource resource);

  /// Updates the resource.
  /// See https://jsonapi.org/format/#crud-updating
  T updateResource(String type, String id, Resource resource);

  /// Replaces the to-one relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-one-relationships
  T replaceToOne(
      String type, String id, String relationship, Identifier identifier);

  /// Deletes the to-one relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-one-relationships
  T deleteToOne(String type, String id, String relationship);

  /// Replaces the to-many relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  T replaceToMany(String type, String id, String relationship,
      Iterable<Identifier> identifiers);

  /// Removes the given identifiers from the to-many relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  T deleteFromRelationship(String type, String id, String relationship,
      Iterable<Identifier> identifiers);

  /// Adds the given identifiers to  the to-many relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  T addToRelationship(String type, String id, String relationship,
      Iterable<Identifier> identifiers);
}
