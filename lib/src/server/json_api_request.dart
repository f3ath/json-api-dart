import 'package:json_api/document.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/relationship_target.dart';
import 'package:json_api/src/server/resource_target.dart';

/// The base interface for JSON:API requests.
abstract class JsonApiRequest {
  /// Calls the appropriate method of [controller] and returns the response
  T handleWith<T>(Controller<T> controller);
}

/// A request to fetch a collection of type [type].
///
/// See: https://jsonapi.org/format/#fetching-resources
class FetchCollection implements JsonApiRequest {
  FetchCollection(this.queryParameters, this.type);

  /// Resource type
  final String type;

  /// URI query parameters
  final Map<String, List<String>> queryParameters;

  @override
  T handleWith<T>(Controller<T> controller) =>
      controller.fetchCollection(type, queryParameters);
}

/// A request to create a resource on the server
///
/// See: https://jsonapi.org/format/#crud-creating
class CreateResource implements JsonApiRequest {
  CreateResource(this.type, this.resource);

  /// Resource type
  final String type;

  /// Resource to create
  final Resource resource;

  @override
  T handleWith<T>(Controller<T> controller) =>
      controller.createResource(type, resource);
}

/// A request to update a resource on the server
///
/// See: https://jsonapi.org/format/#crud-updating
class UpdateResource implements JsonApiRequest {
  UpdateResource(this.target, this.resource);

  final ResourceTarget target;

  /// Resource containing fields to be updated
  final Resource resource;

  @override
  T handleWith<T>(Controller<T> controller) =>
      controller.updateResource(target, resource);
}

/// A request to delete a resource on the server
///
/// See: https://jsonapi.org/format/#crud-deleting
class DeleteResource implements JsonApiRequest {
  DeleteResource(this.target);

  final ResourceTarget target;

  @override
  T handleWith<T>(Controller<T> controller) =>
      controller.deleteResource(target);
}

/// A request to fetch a resource
///
/// See: https://jsonapi.org/format/#fetching-resources
class FetchResource implements JsonApiRequest {
  FetchResource(this.target, this.queryParameters);

  final ResourceTarget target;

  /// URI query parameters
  final Map<String, List<String>> queryParameters;

  @override
  T handleWith<T>(Controller<T> controller) =>
      controller.fetchResource(target, queryParameters);
}

/// A request to fetch a related resource or collection
///
/// See: https://jsonapi.org/format/#fetching
class FetchRelated implements JsonApiRequest {
  FetchRelated(this.target, this.queryParameters);

  final RelationshipTarget target;

  /// URI query parameters
  final Map<String, List<String>> queryParameters;

  @override
  T handleWith<T>(Controller<T> controller) =>
      controller.fetchRelated(target, queryParameters);
}

/// A request to fetch a relationship
///
/// See: https://jsonapi.org/format/#fetching-relationships
class FetchRelationship implements JsonApiRequest {
  FetchRelationship(this.target, this.queryParameters);

  final RelationshipTarget target;

  /// URI query parameters
  final Map<String, List<String>> queryParameters;

  @override
  T handleWith<T>(Controller<T> controller) =>
      controller.fetchRelationship(target, queryParameters);
}

/// A request to delete identifiers from a relationship
///
/// See: https://jsonapi.org/format/#crud-updating-to-many-relationships
class DeleteFromRelationship implements JsonApiRequest {
  DeleteFromRelationship(this.target, Iterable<Identifier> identifiers)
      : identifiers = List.unmodifiable(identifiers);

  final RelationshipTarget target;

  /// The identifiers to delete
  final List<Identifier> identifiers;

  @override
  T handleWith<T>(Controller<T> controller) =>
      controller.deleteFromRelationship(target, identifiers);
}

/// A request to replace a to-one relationship
///
/// See: https://jsonapi.org/format/#crud-updating-to-one-relationships
class ReplaceToOne implements JsonApiRequest {
  ReplaceToOne(this.target, this.identifier);

  final RelationshipTarget target;

  /// The identifier to be put instead of the existing
  final Identifier identifier;

  @override
  T handleWith<T>(Controller<T> controller) =>
      controller.replaceToOne(target, identifier);
}

/// A request to delete a to-one relationship
///
/// See: https://jsonapi.org/format/#crud-updating-to-one-relationships
class DeleteToOne implements JsonApiRequest {
  DeleteToOne(this.target);

  final RelationshipTarget target;

  @override
  T handleWith<T>(Controller<T> controller) =>
      controller.replaceToOne(target, null);
}

/// A request to completely replace a to-many relationship
///
/// See: https://jsonapi.org/format/#crud-updating-to-many-relationships
class ReplaceToMany implements JsonApiRequest {
  ReplaceToMany(this.target, Iterable<Identifier> identifiers)
      : identifiers = List.unmodifiable(identifiers);

  final RelationshipTarget target;

  /// The set of identifiers to replace the current ones
  final List<Identifier> identifiers;

  @override
  T handleWith<T>(Controller<T> controller) =>
      controller.replaceToMany(target, identifiers);
}

/// A request to add identifiers to a to-many relationship
///
/// See: https://jsonapi.org/format/#crud-updating-to-many-relationships
class AddToRelationship implements JsonApiRequest {
  AddToRelationship(this.target, Iterable<Identifier> identifiers)
      : identifiers = List.unmodifiable(identifiers);

  final RelationshipTarget target;

  /// The identifiers to be added to the existing ones
  final List<Identifier> identifiers;

  @override
  T handleWith<T>(Controller<T> controller) =>
      controller.addToRelationship(target, identifiers);
}
