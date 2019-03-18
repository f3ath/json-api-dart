import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/server/contracts/controller.dart';
import 'package:json_api/src/server/numbered_page.dart';
import 'package:uuid/uuid.dart';

import 'dao.dart';

class CarsController implements JsonApiController {
  final Map<String, DAO> dao;

  CarsController(this.dao);

  @override
  Future fetchCollection(FetchCollectionRequest r) async {
    if (!dao.containsKey(r.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    final page = NumberedPage.fromQueryParameters(r.uri.queryParameters,
        total: dao[r.type].length);
    return r.sendCollection(
        dao[r.type]
            .fetchCollection(offset: page.offset)
            .map(dao[r.type].toResource),
        page: page);
  }

  @override
  Future fetchRelated(FetchRelatedRequest r) {
    if (!dao.containsKey(r.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    final res = dao[r.type].fetchByIdAsResource(r.id);
    if (res == null) {
      return r.errorNotFound([JsonApiError(detail: 'Resource not found')]);
    }

    if (res.toOne.containsKey(r.relationship)) {
      final id = res.toOne[r.relationship];
      final resource = dao[id.type].fetchByIdAsResource(id.id);
      return r.sendResource(resource);
    }

    if (res.toMany.containsKey(r.relationship)) {
      final resources = res.toMany[r.relationship]
          .map((id) => dao[id.type].fetchByIdAsResource(id.id));
      return r.sendCollection(resources);
    }
    return r.errorNotFound([JsonApiError(detail: 'Relationship not found')]);
  }

  @override
  Future fetchResource(FetchResourceRequest r) {
    if (!dao.containsKey(r.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    final res = dao[r.type].fetchByIdAsResource(r.id);
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
    if (!dao.containsKey(r.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    final res = dao[r.type].fetchByIdAsResource(r.id);
    if (res == null) {
      return r.errorNotFound([JsonApiError(detail: 'Resource not found')]);
    }

    if (res.toOne.containsKey(r.relationship)) {
      final id = res.toOne[r.relationship];
      return r.sendToOne(id);
    }

    if (res.toMany.containsKey(r.relationship)) {
      final ids = res.toMany[r.relationship];
      return r.sendToMany(ids);
    }
    return r.errorNotFound([JsonApiError(detail: 'Relationship not found')]);
  }

  @override
  Future deleteResource(DeleteResourceRequest r) {
    if (!dao.containsKey(r.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    final res = dao[r.type].fetchByIdAsResource(r.id);
    if (res == null) {
      return r.errorNotFound([JsonApiError(detail: 'Resource not found')]);
    }
    final dependenciesCount = dao[r.type].deleteById(r.id);
    if (dependenciesCount == 0) {
      return r.sendNoContent();
    }
    return r.sendMeta({'dependenciesCount': dependenciesCount});
  }

  Future createResource(CreateResourceRequest r) async {
    if (!dao.containsKey(r.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    if (r.type != r.resource.type) {
      return r.errorConflict([JsonApiError(detail: 'Incompatible type')]);
    }

    if (r.resource.hasId) {
      if (dao[r.type].fetchById(r.resource.id) != null) {
        return r
            .errorConflict([JsonApiError(detail: 'Resource already exists')]);
      }
      final created = dao[r.type].create(r.resource);
      dao[r.type].insert(created);
      return r.sendNoContent();
    }

    final created = dao[r.type].create(Resource(r.resource.type, Uuid().v4(),
        attributes: r.resource.attributes,
        toMany: r.resource.toMany,
        toOne: r.resource.toOne));
    dao[r.type].insert(created);
    return r.sendCreated(dao[r.type].toResource(created));
  }

  @override
  Future updateResource(UpdateResourceRequest r) async {
    if (!dao.containsKey(r.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    if (r.type != r.resource.type) {
      return r.errorConflict([JsonApiError(detail: 'Incompatible type')]);
    }
    if (dao[r.type].fetchById(r.id) == null) {
      return r.errorNotFound([JsonApiError(detail: 'Resource not found')]);
    }
    final updated = dao[r.type].update(r.id, r.resource);
    if (updated == null) {
      return r.sendNoContent();
    }
    return r.sendUpdated(updated);
  }

  @override
  Future replaceToOne(ReplaceToOneRequest r) async {
    if (!dao.containsKey(r.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    dao[r.type].replaceToOne(r.id, r.relationship, r.identifier);
    return r.sendNoContent();
  }

  @override
  Future replaceToMany(ReplaceToManyRequest r) async {
    if (!dao.containsKey(r.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    dao[r.type].replaceToMany(r.id, r.relationship, r.identifiers);
    return r.sendNoContent();
  }

  @override
  Future addToMany(AddToManyRequest r) async {
    if (!dao.containsKey(r.type)) {
      return r.errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    final result = dao[r.type].addToMany(r.id, r.relationship, r.identifiers);
    return r.sendToMany(result);
  }
}
