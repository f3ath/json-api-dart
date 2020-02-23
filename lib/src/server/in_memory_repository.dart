import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/server/repository.dart';
import 'package:json_api/src/server/resource_target.dart';

typedef IdGenerator = String Function();
typedef TypeAttributionCriteria = bool Function(String collection, String type);

/// An in-memory implementation of [Repository]
class InMemoryRepository implements Repository {
  InMemoryRepository(this._collections, {IdGenerator nextId})
      : _nextId = nextId;
  final Map<String, Map<String, Resource>> _collections;
  final IdGenerator _nextId;

  @override
  FutureOr<Resource> create(String collection, Resource resource) async {
    if (!_collections.containsKey(collection)) {
      throw CollectionNotFound("Collection '$collection' does not exist");
    }
    if (collection != resource.type) {
      throw _invalidType(resource, collection);
    }
    for (final relationship in resource.toOne.values
        .followedBy(resource.toMany.values.expand((_) => _))) {
      // Make sure the relationships exist
      await get(ResourceTarget.fromIdentifier(relationship));
    }
    if (resource.id == null) {
      if (_nextId == null) {
        throw UnsupportedOperation('Id generation is not supported');
      }
      final id = _nextId();
      final created = Resource(resource.type, id ?? resource.id,
          attributes: resource.attributes,
          toOne: resource.toOne,
          toMany: resource.toMany);
      _collections[collection][created.id] = created;
      return created;
    }
    if (_collections[collection].containsKey(resource.id)) {
      throw ResourceExists('Resource with this type and id already exists');
    }
    _collections[collection][resource.id] = resource;
    return null;
  }

  @override
  FutureOr<Resource> get(ResourceTarget target) async {
    if (_collections.containsKey(target.type)) {
      final resource = _collections[target.type][target.id];
      if (resource == null) {
        throw ResourceNotFound(
            "Resource '${target.id}' does not exist in '${target.type}'");
      }
      return resource;
    }
    throw CollectionNotFound("Collection '${target.type}' does not exist");
  }

  @override
  FutureOr<Resource> update(ResourceTarget target, Resource resource) async {
    if (target.type != resource.type) {
      throw _invalidType(resource, target.type);
    }
    final original = await get(target);
    if (resource.attributes.isEmpty &&
        resource.toOne.isEmpty &&
        resource.toMany.isEmpty &&
        resource.id == target.id) {
      return null;
    }
    final updated = Resource(
      original.type,
      original.id,
      attributes: {...original.attributes}..addAll(resource.attributes),
      toOne: {...original.toOne}..addAll(resource.toOne),
      toMany: {...original.toMany}..addAll(resource.toMany),
    );
    _collections[target.type][target.id] = updated;
    return updated;
  }

  @override
  FutureOr<void> delete(ResourceTarget target) async {
    await get(target);
    _collections[target.type].remove(target.id);
    return null;
  }

  @override
  FutureOr<Collection<Resource>> getCollection(String collection) async {
    if (_collections.containsKey(collection)) {
      return Collection(
          _collections[collection].values, _collections[collection].length);
    }
    throw CollectionNotFound("Collection '$collection' does not exist");
  }

  InvalidType _invalidType(Resource resource, String collection) {
    return InvalidType(
        "Type '${resource.type}' does not belong in '$collection'");
  }
}
