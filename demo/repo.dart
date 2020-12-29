import 'package:json_api/document.dart';
import 'package:json_api/src/nullable.dart';

abstract class Repo {
  /// Fetches a collection.
  /// Throws [CollectionNotFound].
  Stream<Model> fetchCollection(String type);

  /// Throws [ResourceNotFound]
  Future<Model> fetch(String type, String id);

  /// Throws [CollectionNotFound].
  Future<void> persist(String type, Model model);

  /// Add refs to a to-many relationship
  /// Throws [CollectionNotFound].
  /// Throws [ResourceNotFound].
  /// Throws [RelationshipNotFound].
  Stream<Identity> addMany(
      String type, String id, String rel, Iterable<Identity> refs);

  /// Delete the resource
  Future<void> delete(String type, String id);

  /// Updates the model
  Future<void> update(String type, String id, ModelProps props);

  Future<void> replaceOne(String type, String id, String rel, Identity? ref);

  /// Deletes refs from the to-many relationship.
  /// Returns the new actual refs.
  Stream<Identity> deleteMany(
      String type, String id, String rel, Iterable<Identity> refs);

  /// Replaces refs in the to-many relationship.
  /// Returns the new actual refs.
  Stream<Identity> replaceMany(
      String type, String id, String rel, Iterable<Identity> refs);
}

class CollectionNotFound implements Exception {}

class ResourceNotFound implements Exception {}

class RelationshipNotFound implements Exception {}

class Ref with Identity {
  Ref(this.type, this.id);

  static Ref of(Identity identity) => Ref(identity.type, identity.id);

  @override
  final String type;
  @override
  final String id;

  @override
  final hashCode = 0;

  @override
  bool operator ==(Object other) =>
      other is Ref && type == other.type && id == other.id;
}

class ModelProps {
  static ModelProps fromResource(ResourceProperties res) {
    final props = ModelProps();
    res.attributes.forEach((key, value) {
      props.attributes[key] = value;
    });
    res.relationships.forEach((key, value) {
      if (value is ToOne) {
        props.one[key] = nullable(Ref.of)(value.identifier);
        return;
      }
      if (value is ToMany) {
        props.many[key] = Set.of(value.map(Ref.of));
        return;
      }
    });
    return props;
  }

  final attributes = <String, Object?>{};
  final one = <String, Ref?>{};
  final many = <String, Set<Ref>>{};

  void setFrom(ModelProps other) {
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

/// A model of a resource. Essentially, this is the core of a resource object.
class Model extends ModelProps {
  Model(this.id);

  final String id;

  Resource toResource(String type) {
    final res = Resource(type, id);
    attributes.forEach((key, value) {
      res.attributes[key] = value;
    });
    one.forEach((key, value) {
      res.relationships[key] =
          (value == null ? ToOne.empty() : ToOne(Identifier.of(value)));
    });
    many.forEach((key, value) {
      res.relationships[key] = ToMany(value.map(Identifier.of));
    });
    return res;
  }
}
