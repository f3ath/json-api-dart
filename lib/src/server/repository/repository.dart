import 'dart:async';

import 'package:json_api/src/document/resource.dart';

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
  /// does not belong to the collection. This exception will be converted to HTTP 409
  /// error.
  FutureOr<Resource> create(String collection, Resource resource);

  /// Returns the resource from [collection] by [id].
  FutureOr<Resource> get(String collection, String id);

  /// Updates the resource identified by [collection] and [id].
  /// If the resource was modified during update, returns the modified resource.
  /// Otherwise returns null.
  FutureOr<Resource> update(String collection, String id, Resource resource);

  /// Deletes the resource identified by [type] and [id]
  FutureOr<void> delete(String type, String id);

  /// Returns a collection of resources
  FutureOr<Collection<Resource>> getCollection(String collection);
}

/// A collection of elements (e.g. resources) returned by the server.
class Collection<T> {
  final Iterable<T> elements;

  /// Total count of the elements on the server. May be null.
  final int total;

  Collection(this.elements, [this.total]);
}

class CollectionNotFound implements Exception {
  final String message;

  CollectionNotFound(this.message);
}

class ResourceNotFound implements Exception {
  final String message;

  ResourceNotFound(this.message);
}

class UnsupportedOperation implements Exception {
  final String message;

  UnsupportedOperation(this.message);
}

class InvalidType implements Exception {
  final String message;

  InvalidType(this.message);
}

class ResourceExists implements Exception {
  final String message;

  ResourceExists(this.message);
}
