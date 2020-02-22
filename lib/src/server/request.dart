import 'package:json_api/document.dart';
import 'package:json_api/src/server/request_handler.dart';

/// A base interface for JSON:API requests.
abstract class Request {
  /// Calls the appropriate method of [controller] and returns the response
  T handleWith<T>(RequestHandler<T> controller);
}

/// A request to fetch a collection of type [type].
///
/// See: https://jsonapi.org/format/#fetching-resources
class FetchCollection implements Request {
  FetchCollection(this.queryParameters, this.type);

  /// Resource type
  final String type;

  /// URI query parameters
  final Map<String, List<String>> queryParameters;

  @override
  T handleWith<T>(RequestHandler<T> controller) =>
      controller.fetchCollection(type, queryParameters);
}

/// A request to create a resource on the server
///
/// See: https://jsonapi.org/format/#crud-creating
class CreateResource implements Request {
  CreateResource(this.type, this.resource);

  /// Resource type
  final String type;

  /// Resource to create
  final Resource resource;

  @override
  T handleWith<T>(RequestHandler<T> controller) =>
      controller.createResource(type, resource);
}

/// A request to update a resource on the server
///
/// See: https://jsonapi.org/format/#crud-updating
class UpdateResource implements Request {
  UpdateResource(this.type, this.id, this.resource);

  /// Resource type
  final String type;

  /// Resource id
  final String id;

  /// Resource containing fields to be updated
  final Resource resource;

  @override
  T handleWith<T>(RequestHandler<T> controller) =>
      controller.updateResource(type, id, resource);
}

/// A request to delete a resource on the server
///
/// See: https://jsonapi.org/format/#crud-deleting
class DeleteResource implements Request {
  DeleteResource(this.type, this.id);

  /// Resource type
  final String type;

  /// Resource id
  final String id;

  @override
  T handleWith<T>(RequestHandler<T> controller) =>
      controller.deleteResource(type, id);
}

/// A request to fetch a resource
///
/// See: https://jsonapi.org/format/#fetching-resources
class FetchResource implements Request {
  FetchResource(this.type, this.id, this.queryParameters);

  /// Resource type
  final String type;

  /// Resource id
  final String id;

  /// URI query parameters
  final Map<String, List<String>> queryParameters;

  @override
  T handleWith<T>(RequestHandler<T> controller) =>
      controller.fetchResource(type, id, queryParameters);
}

/// A request to fetch a related resource or collection
///
/// See: https://jsonapi.org/format/#fetching
class FetchRelated implements Request {
  FetchRelated(this.type, this.id, this.relationship, this.queryParameters);

  /// Resource type
  final String type;

  /// Resource id
  final String id;

  /// Relationship name
  final String relationship;

  /// URI query parameters
  final Map<String, List<String>> queryParameters;

  @override
  T handleWith<T>(RequestHandler<T> controller) =>
      controller.fetchRelated(type, id, relationship, queryParameters);
}

/// A request to fetch a relationship
///
/// See: https://jsonapi.org/format/#fetching-relationships
class FetchRelationship implements Request {
  FetchRelationship(
      this.type, this.id, this.relationship, this.queryParameters);

  /// Resource type
  final String type;

  /// Resource id
  final String id;

  /// Relationship name
  final String relationship;

  /// URI query parameters
  final Map<String, List<String>> queryParameters;

  @override
  T handleWith<T>(RequestHandler<T> controller) =>
      controller.fetchRelationship(type, id, relationship, queryParameters);
}

/// A request to delete identifiers from a relationship
///
/// See: https://jsonapi.org/format/#crud-updating-to-many-relationships
class DeleteFromRelationship implements Request {
  DeleteFromRelationship(
      this.type, this.id, this.relationship, this.identifiers);

  /// Resource type
  final String type;

  /// Resource id
  final String id;

  /// Relationship name
  final String relationship;

  /// The identifiers to delete
  final Iterable<Identifier> identifiers;

  @override
  T handleWith<T>(RequestHandler<T> controller) =>
      controller.deleteFromRelationship(type, id, relationship, identifiers);
}

/// A request to replace a to-one relationship
///
/// See: https://jsonapi.org/format/#crud-updating-to-one-relationships
class ReplaceToOne implements Request {
  ReplaceToOne(this.type, this.id, this.relationship, this.identifier);

  /// Resource type
  final String type;

  /// Resource id
  final String id;

  /// Relationship name
  final String relationship;

  /// The identifier to be put instead of the existing
  final Identifier identifier;

  @override
  T handleWith<T>(RequestHandler<T> controller) =>
      controller.replaceToOne(type, id, relationship, identifier);
}

/// A request to delete a to-one relationship
///
/// See: https://jsonapi.org/format/#crud-updating-to-one-relationships
class DeleteToOne implements Request {
  DeleteToOne(this.type, this.id, this.relationship);

  /// Resource type
  final String type;

  /// Resource id
  final String id;

  final String relationship;

  @override
  T handleWith<T>(RequestHandler<T> controller) =>
      controller.replaceToOne(type, id, relationship, null);
}

/// A request to completely replace a to-many relationship
///
/// See: https://jsonapi.org/format/#crud-updating-to-many-relationships
class ReplaceToMany implements Request {
  ReplaceToMany(this.type, this.id, this.relationship, this.identifiers);

  /// Resource type
  final String type;

  /// Resource id
  final String id;

  /// Relationship name
  final String relationship;

  /// The set of identifiers to replace the current ones
  final Iterable<Identifier> identifiers;

  @override
  T handleWith<T>(RequestHandler<T> controller) =>
      controller.replaceToMany(type, id, relationship, identifiers);
}

/// A request to add identifiers to a to-many relationship
///
/// See: https://jsonapi.org/format/#crud-updating-to-many-relationships
class AddToRelationship implements Request {
  AddToRelationship(this.type, this.id, this.relationship, this.identifiers);

  /// Resource type
  final String type;

  /// Resource id
  final String id;

  /// Relationship name
  final String relationship;

  /// The identifiers to be added to the existing ones
  final Iterable<Identifier> identifiers;

  @override
  T handleWith<T>(RequestHandler<T> controller) =>
      controller.addToRelationship(type, id, relationship, identifiers);
}
