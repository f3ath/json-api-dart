import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/query.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/server/collection.dart';

/// The Repository translates CRUD operations on resources to actual data
/// manipulation.
abstract class Repository {
  /// Creates the [resource] in the [collection].
  /// If the resource was modified during creation,
  /// this method must return the modified resource (e.g. with the generated id).
  /// Otherwise must return null.
  ///
  /// Throws [CollectionNotFound] if there is no such [collection].

  /// Throws [ResourceNotFound] if one or more related resources are not found.
  ///
  /// Throws [UnsupportedOperation] if the operation
  /// is not supported (e.g. the client sent a resource without the id, but
  /// the id generation is not supported by this repository). This exception
  /// will be converted to HTTP 403 error.
  ///
  /// Throws [InvalidType] if the [resource]
  /// does not belong to the collection.
  Future<Resource> create(String collection, Resource resource);

  /// Returns the resource by [type] and [id].
  Future<Resource> get(String type, String id);

  /// Updates the resource identified by [target].
  /// If the resource was modified during update, returns the modified resource.
  /// Otherwise returns null.
  Future<Resource> update(String type, String id, Resource resource);

  /// Deletes the resource identified by [target]
  Future<void> delete(String type, String id);

  /// Returns a collection of resources
  Future<Collection<Resource>> getCollection(String collection,
      {int limit, int offset, List<SortField> sort});
}

/// Thrown when the requested collection does not exist
/// This exception should result in HTTP 404.
class CollectionNotFound implements Exception {
  CollectionNotFound(this.message);

  final String message;
}

/// Thrown when the requested resource does not exist.
/// This exception should result in HTTP 404.
class ResourceNotFound implements Exception {
  ResourceNotFound(this.message);

  final String message;
}

/// Thrown if the operation
/// is not supported (e.g. the client sent a resource without the id, but
/// the id generation is not supported by this repository).
/// This exception should result in HTTP 403.
class UnsupportedOperation implements Exception {
  UnsupportedOperation(this.message);

  final String message;
}

/// Thrown if the resource type does not belong to the collection.
/// This exception should result in HTTP 409.
class InvalidType implements Exception {
  InvalidType(this.message);

  final String message;
}

/// Thrown if the client asks to create a resource which already exists.
/// This exception should result in HTTP 409.
class ResourceExists implements Exception {
  ResourceExists(this.message);

  final String message;
}
