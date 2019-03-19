import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/server.dart';
import 'package:uuid/uuid.dart';

import 'dao.dart';

class CarsController implements JsonApiController {
  final Map<String, DAO> dao;

  CarsController(this.dao);

  @override
  Future fetchCollection(FetchCollectionRequest r) async {
    if (!dao.containsKey(r.target.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    final page = NumberedPage.fromQueryParameters(r.uri.queryParameters,
        total: dao[r.target.type].length);
    return r.sendCollection(Collection(
        dao[r.target.type]
            .fetchCollection(offset: page.offset)
            .map(dao[r.target.type].toResource),
        page: page));
  }

  @override
  Future fetchRelated(FetchRelatedRequest r) {
    if (!dao.containsKey(r.target.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    final res = dao[r.target.type].fetchByIdAsResource(r.target.id);
    if (res == null) {
      return r.errorNotFound([JsonApiError(detail: 'Resource not found')]);
    }

    if (res.toOne.containsKey(r.target.relationship)) {
      final id = res.toOne[r.target.relationship];
      final resource = dao[id.type].fetchByIdAsResource(id.id);
      return r.sendResource(resource);
    }

    if (res.toMany.containsKey(r.target.relationship)) {
      final resources = res.toMany[r.target.relationship]
          .map((id) => dao[id.type].fetchByIdAsResource(id.id));
      return r.sendCollection(Collection(resources));
    }
    return r.errorNotFound([JsonApiError(detail: 'Relationship not found')]);
  }

  @override
  Future fetchResource(FetchResourceRequest r) {
    if (!dao.containsKey(r.target.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    final res = dao[r.target.type].fetchByIdAsResource(r.target.id);
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
    if (!dao.containsKey(r.target.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    final res = dao[r.target.type].fetchByIdAsResource(r.target.id);
    if (res == null) {
      return r.errorNotFound([JsonApiError(detail: 'Resource not found')]);
    }

    if (res.toOne.containsKey(r.target.relationship)) {
      final id = res.toOne[r.target.relationship];
      return r.sendToOne(id);
    }

    if (res.toMany.containsKey(r.target.relationship)) {
      final ids = res.toMany[r.target.relationship];
      return r.sendToMany(ids);
    }
    return r.errorNotFound([JsonApiError(detail: 'Relationship not found')]);
  }

  @override
  Future deleteResource(DeleteResourceRequest r) {
    if (!dao.containsKey(r.target.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    final res = dao[r.target.type].fetchByIdAsResource(r.target.id);
    if (res == null) {
      return r.errorNotFound([JsonApiError(detail: 'Resource not found')]);
    }
    final dependenciesCount = dao[r.target.type].deleteById(r.target.id);
    if (dependenciesCount == 0) {
      return r.sendNoContent();
    }
    return r.sendMeta({'dependenciesCount': dependenciesCount});
  }

  Future createResource(CreateResourceRequest r) async {
    if (!dao.containsKey(r.target.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    if (r.target.type != r.resource.type) {
      return r.errorConflict([JsonApiError(detail: 'Incompatible type')]);
    }

    if (r.resource.hasId) {
      if (dao[r.target.type].fetchById(r.resource.id) != null) {
        return r
            .errorConflict([JsonApiError(detail: 'Resource already exists')]);
      }
      final created = dao[r.target.type].create(r.resource);
      dao[r.target.type].insert(created);
      return r.sendNoContent();
    }

    final created = dao[r.target.type].create(Resource(
        r.resource.type, Uuid().v4(),
        attributes: r.resource.attributes,
        toMany: r.resource.toMany,
        toOne: r.resource.toOne));
    dao[r.target.type].insert(created);
    return r.sendCreated(dao[r.target.type].toResource(created));
  }

  @override
  Future updateResource(UpdateResourceRequest r) async {
    if (!dao.containsKey(r.target.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    if (r.target.type != r.resource.type) {
      return r.errorConflict([JsonApiError(detail: 'Incompatible type')]);
    }
    if (dao[r.target.type].fetchById(r.target.id) == null) {
      return r.errorNotFound([JsonApiError(detail: 'Resource not found')]);
    }
    final updated = dao[r.target.type].update(r.target.id, r.resource);
    if (updated == null) {
      return r.sendNoContent();
    }
    return r.sendUpdated(updated);
  }

  @override
  Future replaceToOne(ReplaceToOneRequest r) async {
    if (!dao.containsKey(r.target.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    dao[r.target.type]
        .replaceToOne(r.target.id, r.target.relationship, r.identifier);
    return r.sendNoContent();
  }

  @override
  Future replaceToMany(ReplaceToManyRequest r) async {
    if (!dao.containsKey(r.target.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    dao[r.target.type]
        .replaceToMany(r.target.id, r.target.relationship, r.identifiers);
    return r.sendNoContent();
  }

  @override
  Future addToMany(AddToManyRequest r) async {
    if (!dao.containsKey(r.target.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    final result = dao[r.target.type]
        .addToMany(r.target.id, r.target.relationship, r.identifiers);
    return r.sendToMany(result);
  }
}
