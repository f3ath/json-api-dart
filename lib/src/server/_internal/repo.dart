abstract class Repo {
  /// Fetches a collection.
  /// Throws [CollectionNotFound].
  Stream<Entity<Model>> fetchCollection(String type);

  Future<Model /*?*/ > fetch(String type, String id);

  Future<void> persist(String type, String id, Model model);

  /// Add refs to a to-many relationship
  Stream<String> addMany(
      String type, String id, String rel, Iterable<String> refs);

  /// Delete the model
  Future<void> delete(String type, String id);

  /// Updates the model
  Future<void> update(String type, String id, Model model);

  Future<void> replaceOne(
      String type, String id, String relationship, String key);

  Future<void> deleteOne(String type, String id, String relationship);

  /// Deletes refs from the to-many relationship.
  /// Returns the new actual refs.
  Stream<String> deleteMany(
      String type, String id, String relationship, Iterable<String> refs);

  /// Replaces refs in the to-many relationship.
  /// Returns the new actual refs.
  Stream<String> replaceMany(
      String type, String id, String relationship, Iterable<String> refs);
}

class CollectionNotFound implements Exception {}

class Entity<M> {
  const Entity(this.id, this.model);

  final String id;

  final M model;
}

class Model {
  final attributes = <String, Object /*?*/ >{};
  final one = <String, String>{};
  final many = <String, Set<String>>{};

  void addMany(String relationship, Iterable<String> refs) {
    many[relationship] ??= <String>{};
    many[relationship].addAll(refs);
  }

  void setFrom(Model other) {
    other.attributes.forEach((key, value) {
      attributes[key] = value;
    });
    other.one.forEach((key, value) {
      one[key] = value;
    });
    other.many.forEach((key, value) {
      many[key] = {...value};
    });
  }
}
