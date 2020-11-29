import 'package:json_api/core.dart';

abstract class Repo {
  /// Fetches a collection.
  /// Throws [CollectionNotFound].
  Stream<Model> fetchCollection(String type);

  /// Throws [ResourceNotFound]
  Future<Model> fetch(Ref ref);

  /// Throws [CollectionNotFound].
  Future<void> persist(Model model);

  /// Add refs to a to-many relationship
  /// Throws [CollectionNotFound].
  /// Throws [ResourceNotFound].
  /// Throws [RelationshipNotFound].
  Stream<Ref> addMany(Ref ref, String rel, Iterable<Ref> refs);

  /// Delete the resource
  Future<void> delete(Ref ref);

  /// Updates the model
  Future<void> update(Ref ref, ModelProps props);

  Future<void> replaceOne(Ref ref, String rel, Ref? one);

  /// Deletes refs from the to-many relationship.
  /// Returns the new actual refs.
  Stream<Ref> deleteMany(Ref ref, String rel, Iterable<Ref> refs);

  /// Replaces refs in the to-many relationship.
  /// Returns the new actual refs.
  Stream<Ref> replaceMany(Ref ref, String rel, Iterable<Ref> refs);
}

class CollectionNotFound implements Exception {}

class ResourceNotFound implements Exception {}

class RelationshipNotFound implements Exception {
  RelationshipNotFound(this.message);

  final String message;

  @override
  String toString() => message;
}
