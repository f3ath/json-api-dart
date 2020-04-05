import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/query.dart';
import 'package:json_api/src/server/collection.dart';
import 'package:json_api/src/server/repository.dart';

typedef IdGenerator = String Function();
typedef TypeAttributionCriteria = bool Function(String collection, String type);

/// An in-memory implementation of [Repository]
class InMemoryRepository implements Repository {
  InMemoryRepository(this._collections, {IdGenerator nextId})
      : _nextId = nextId;
  final Map<String, Map<String, Resource>> _collections;
  final IdGenerator _nextId;

  @override
  Future<Resource> create(String collection, Resource resource) async {
    if (!_collections.containsKey(collection)) {
      throw CollectionNotFound("Collection '$collection' does not exist");
    }
    if (collection != resource.type) {
      throw _invalidType(resource, collection);
    }
    for (final relationship in resource.toOne.values
        .followedBy(resource.toMany.values.expand((_) => _))) {
      // Make sure the relationships exist
      await get(relationship.type, relationship.id);
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
  Future<Resource> get(String type, String id) async {
    if (_collections.containsKey(type)) {
      final resource = _collections[type][id];
      if (resource == null) {
        throw ResourceNotFound("Resource '${id}' does not exist in '${type}'");
      }
      return resource;
    }
    throw CollectionNotFound("Collection '${type}' does not exist");
  }

  @override
  Future<Resource> update(String type, String id, Resource resource) async {
    if (type != resource.type) {
      throw _invalidType(resource, type);
    }
    final original = await get(type, id);
    if (resource.attributes.isEmpty &&
        resource.toOne.isEmpty &&
        resource.toMany.isEmpty &&
        resource.id == id) {
      return null;
    }
    final updated = Resource(
      original.type,
      original.id,
      attributes: {...original.attributes}..addAll(resource.attributes),
      toOne: {...original.toOne}..addAll(resource.toOne),
      toMany: {...original.toMany}..addAll(resource.toMany),
    );
    _collections[type][id] = updated;
    return updated;
  }

  @override
  Future<void> delete(String type, String id) async {
    await get(type, id);
    _collections[type].remove(id);
    return null;
  }

  @override
  Future<Collection<Resource>> getCollection(String type,
      {int limit, int offset, List<SortField> sort}) async {
    if (_collections.containsKey(type)) {
      return Collection(_collections[type].values, _collections[type].length);
    }
    throw CollectionNotFound("Collection '$type' does not exist");
  }

  InvalidType _invalidType(Resource resource, String collection) {
    return InvalidType(
        "Type '${resource.type}' does not belong in '$collection'");
  }
}
