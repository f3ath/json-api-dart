import 'package:json_api/document.dart';
import 'package:json_api/src/server/relationship_target.dart';
import 'package:json_api/src/server/resource_target.dart';

/// This is a controller consolidating all possible requests a JSON:API server
/// may handle.
abstract class Controller<T> {
  /// Finds an returns a primary resource collection.
  /// See https://jsonapi.org/format/#fetching-resources
  T fetchCollection(String type, Map<String, List<String>> queryParameters);

  /// Finds an returns a primary resource.
  /// See https://jsonapi.org/format/#fetching-resources
  T fetchResource(
      ResourceTarget target, Map<String, List<String>> queryParameters);

  /// Finds an returns a related resource or a collection of related resources.
  /// See https://jsonapi.org/format/#fetching-resources
  T fetchRelated(
      RelationshipTarget target, Map<String, List<String>> queryParameters);

  /// Finds an returns a relationship of a primary resource.
  /// See https://jsonapi.org/format/#fetching-relationships
  T fetchRelationship(
      RelationshipTarget target, Map<String, List<String>> queryParameters);

  /// Deletes the resource.
  /// See https://jsonapi.org/format/#crud-deleting
  T deleteResource(ResourceTarget target);

  /// Creates a new resource in the collection.
  /// See https://jsonapi.org/format/#crud-creating
  T createResource(String type, Resource resource);

  /// Updates the resource.
  /// See https://jsonapi.org/format/#crud-updating
  T updateResource(ResourceTarget target, Resource resource);

  /// Replaces the to-one relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-one-relationships
  T replaceToOne(RelationshipTarget target, Identifier identifier);

  /// Deletes the to-one relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-one-relationships
  T deleteToOne(RelationshipTarget target);

  /// Replaces the to-many relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  T replaceToMany(RelationshipTarget target, Iterable<Identifier> identifiers);

  /// Removes the given identifiers from the to-many relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  T deleteFromRelationship(
      RelationshipTarget target, Iterable<Identifier> identifiers);

  /// Adds the given identifiers to  the to-many relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  T addToRelationship(
      RelationshipTarget target, Iterable<Identifier> identifiers);
}
