import 'package:json_api/document.dart';
import 'package:json_api/src/server/controller_request.dart';
import 'package:json_api/src/server/controller_response.dart';

/// This is a controller consolidating all possible requests a JSON:API server
/// may handle.
abstract class Controller {
  /// Finds an returns a primary resource collection.
  /// See https://jsonapi.org/format/#fetching-resources
  Future<ControllerResponse> fetchCollection(CollectionRequest request);

  /// Finds an returns a primary resource.
  /// See https://jsonapi.org/format/#fetching-resources
  Future<ControllerResponse> fetchResource(ResourceRequest request);

  /// Finds an returns a related resource or a collection of related resources.
  /// See https://jsonapi.org/format/#fetching-resources
  Future<ControllerResponse> fetchRelated(RelatedRequest request);

  /// Finds an returns a relationship of a primary resource.
  /// See https://jsonapi.org/format/#fetching-relationships
  Future<ControllerResponse> fetchRelationship(RelationshipRequest request);

  /// Deletes the resource.
  /// See https://jsonapi.org/format/#crud-deleting
  Future<ControllerResponse> deleteResource(ResourceRequest request);

  /// Creates a new resource in the collection.
  /// See https://jsonapi.org/format/#crud-creating
  Future<ControllerResponse> createResource(
      CollectionRequest request, Resource resource);

  /// Updates the resource.
  /// See https://jsonapi.org/format/#crud-updating
  Future<ControllerResponse> updateResource(
      ResourceRequest request, Resource resource);

  /// Replaces the to-one relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-one-relationships
  Future<ControllerResponse> replaceToOne(
      RelationshipRequest request, Identifier identifier);

  /// Replaces the to-many relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<ControllerResponse> replaceToMany(
      RelationshipRequest request, List<Identifier> identifiers);

  /// Removes the given identifiers from the to-many relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<ControllerResponse> deleteFromRelationship(
      RelationshipRequest request, List<Identifier> identifiers);

  /// Adds the given identifiers to  the to-many relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<ControllerResponse> addToRelationship(
      RelationshipRequest request, List<Identifier> identifiers);
}
