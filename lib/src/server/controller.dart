import 'package:json_api/document.dart';
import 'package:json_api/src/server/response.dart';
import 'package:json_api/src/server/request.dart';
import 'package:json_api/src/server/target.dart';

/// This is a controller consolidating all possible requests a JSON:API server
/// may handle.
abstract class Controller {
  /// Finds an returns a primary resource collection.
  /// See https://jsonapi.org/format/#fetching-resources
  Future<Response> fetchCollection(Request<CollectionTarget> request);

  /// Finds an returns a primary resource.
  /// See https://jsonapi.org/format/#fetching-resources
  Future<Response> fetchResource(Request<ResourceTarget> request);

  /// Finds an returns a related resource or a collection of related resources.
  /// See https://jsonapi.org/format/#fetching-resources
  Future<Response> fetchRelated(Request<RelationshipTarget> request);

  /// Finds an returns a relationship of a primary resource.
  /// See https://jsonapi.org/format/#fetching-relationships
  Future<Response> fetchRelationship(
      Request<RelationshipTarget> request);

  /// Deletes the resource.
  /// See https://jsonapi.org/format/#crud-deleting
  Future<Response> deleteResource(Request<ResourceTarget> request);

  /// Creates a new resource in the collection.
  /// See https://jsonapi.org/format/#crud-creating
  Future<Response> createResource(
      Request<CollectionTarget> request, Resource resource);

  /// Updates the resource.
  /// See https://jsonapi.org/format/#crud-updating
  Future<Response> updateResource(
      Request<ResourceTarget> request, Resource resource);

  /// Replaces the to-one relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-one-relationships
  Future<Response> replaceToOne(
      Request<RelationshipTarget> request, Identifier identifier);

  /// Replaces the to-many relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<Response> replaceToMany(
      Request<RelationshipTarget> request, List<Identifier> identifiers);

  /// Removes the given identifiers from the to-many relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<Response> deleteFromRelationship(
      Request<RelationshipTarget> request, List<Identifier> identifiers);

  /// Adds the given identifiers to  the to-many relationship.
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<Response> addToRelationship(
      Request<RelationshipTarget> request, List<Identifier> identifiers);
}
