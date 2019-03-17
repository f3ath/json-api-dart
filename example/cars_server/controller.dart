import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/numbered_page.dart';
import 'package:uuid/uuid.dart';

import 'dao.dart';

class CarsController implements JsonApiController {
  final Map<String, DAO> dao;

  CarsController(this.dao);

  @override
  Future fetchCollection(FetchCollectionRequest r) async {
    if (!dao.containsKey(r.route.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    final page = NumberedPage.fromQueryParameters(r.route.parameters,
        total: dao[r.route.type].length);
    return r.sendCollection(
        dao[r.route.type]
            .fetchCollection(offset: page.offset)
            .map(dao[r.route.type].toResource),
        page: page);
  }

  @override
  Future fetchRelated(FetchRelatedRequest r) {
    if (!dao.containsKey(r.route.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    final res = dao[r.route.type].fetchByIdAsResource(r.route.id);
    if (res == null) {
      return r.errorNotFound([JsonApiError(detail: 'Resource not found')]);
    }

    if (res.toOne.containsKey(r.route.relationship)) {
      final id = res.toOne[r.route.relationship];
      final resource = dao[id.type].fetchByIdAsResource(id.id);
      return r.sendResource(resource);
    }

    if (res.toMany.containsKey(r.route.relationship)) {
      final resources = res.toMany[r.route.relationship]
          .map((id) => dao[id.type].fetchByIdAsResource(id.id));
      return r.sendCollection(resources);
    }
    return r.errorNotFound([JsonApiError(detail: 'Relationship not found')]);
  }

  @override
  Future fetchResource(FetchResourceRequest r) {
    if (!dao.containsKey(r.route.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    final res = dao[r.route.type].fetchByIdAsResource(r.route.id);
    if (res == null) {
      return r.errorNotFound([JsonApiError(detail: 'Resource not found')]);
    }
    final fetchById = (Identifier _) => dao[_.type].fetchByIdAsResource(_.id);

    final children = res.toOne.values
        .map(fetchById)
        .followedBy(res.toMany.values.expand((_) => _.map(fetchById)));

    return r.sendResource(res, included: children);
  }

  @override
  Future fetchRelationship(FetchRelationshipRequest r) {
    if (!dao.containsKey(r.route.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    final res = dao[r.route.type].fetchByIdAsResource(r.route.id);
    if (res == null) {
      return r.errorNotFound([JsonApiError(detail: 'Resource not found')]);
    }

    if (res.toOne.containsKey(r.route.relationship)) {
      final id = res.toOne[r.route.relationship];
      return r.sendToOne(id);
    }

    if (res.toMany.containsKey(r.route.relationship)) {
      final ids = res.toMany[r.route.relationship];
      return r.sendToMany(ids);
    }
    return r.errorNotFound([JsonApiError(detail: 'Relationship not found')]);
  }

  @override
  Future deleteResource(DeleteResourceRequest r) {
    if (!dao.containsKey(r.route.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    final res = dao[r.route.type].fetchByIdAsResource(r.route.id);
    if (res == null) {
      return r.errorNotFound([JsonApiError(detail: 'Resource not found')]);
    }
    final dependenciesCount = dao[r.route.type].deleteById(r.route.id);
    if (dependenciesCount == 0) {
      return r.sendNoContent();
    }
    return r.sendMeta({'dependenciesCount': dependenciesCount});
  }

  Future createResource(CreateResourceRequest r) async {
    if (!dao.containsKey(r.route.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    final resource = await r.getResource();
    if (r.route.type != resource.type) {
      return r.errorConflict([JsonApiError(detail: 'Incompatible type')]);
    }

    if (resource.hasId) {
      if (dao[r.route.type].fetchById(resource.id) != null) {
        return r
            .errorConflict([JsonApiError(detail: 'Resource already exists')]);
      }
      final created = dao[r.route.type].create(resource);
      dao[r.route.type].insert(created);
      return r.sendNoContent();
    }

    final created = dao[r.route.type].create(Resource(
        resource.type, Uuid().v4(),
        attributes: resource.attributes,
        toMany: resource.toMany,
        toOne: resource.toOne));
    dao[r.route.type].insert(created);
    return r.sendCreated(dao[r.route.type].toResource(created));
  }

  @override
  Future updateResource(UpdateResourceRequest r) async {
    if (!dao.containsKey(r.route.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    final resource = await r.getResource();
    if (r.route.type != resource.type) {
      return r.errorConflict([JsonApiError(detail: 'Incompatible type')]);
    }
    if (dao[r.route.type].fetchById(r.route.id) == null) {
      return r.errorNotFound([JsonApiError(detail: 'Resource not found')]);
    }
    final updated = dao[r.route.type].update(r.route.id, resource);
    if (updated == null) {
      return r.sendNoContent();
    }
    return r.sendUpdated(updated);
  }

  @override
  Future replaceRelationship(ReplaceRelationshipRequest r) async {
    if (!dao.containsKey(r.route.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    final rel = await r.getRelationship();
    if (rel is ToOne) {
      dao[r.route.type]
          .replaceToOne(r.route.id, r.route.relationship, rel.toIdentifier());
      return r.sendNoContent();
    }
    if (rel is ToMany) {
      dao[r.route.type]
          .replaceToMany(r.route.id, r.route.relationship, rel.identifiers);
      return r.sendNoContent();
    }
  }

  @override
  Future addToRelationship(AddToRelationshipRequest r) async {
    if (!dao.containsKey(r.route.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    final result = dao[r.route.type]
        .addToMany(r.route.id, r.route.relationship, await r.getIdentifiers());
    return r.sendToMany(result);
  }
}
