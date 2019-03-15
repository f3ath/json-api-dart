import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/server/numbered_page.dart';
import 'package:json_api/src/server/server.dart';
import 'package:uuid/uuid.dart';

import 'dao.dart';

class CarsController implements JsonApiController {
  final Map<String, DAO> dao;

  CarsController(this.dao);

  @override
  Future fetchCollection(FetchCollection r) {
    if (!dao.containsKey(r.route.type)) {
      return r.notFound([ErrorObject(detail: 'Unknown resource type')]);
    }
    final page = NumberedPage.fromQueryParameters(r.queryParameters,
        total: dao[r.route.type].length);
    return r.collection(Collection(
        dao[r.route.type]
            .fetchCollection(offset: page.number - 1)
            .map(dao[r.route.type].toResource),
        page: page));
  }

  @override
  Future fetchRelated(FetchRelated r) {
    if (!dao.containsKey(r.route.type)) {
      return r.notFound([ErrorObject(detail: 'Unknown resource type')]);
    }
    final res = dao[r.route.type].fetchByIdAsResource(r.route.id);
    if (res == null) {
      return r.notFound([ErrorObject(detail: 'Resource not found')]);
    }

    if (res.toOne.containsKey(r.route.relationship)) {
      final id = res.toOne[r.route.relationship];
      final resource = dao[id.type].fetchByIdAsResource(id.id);
      return r.resource(resource);
    }

    if (res.toMany.containsKey(r.route.relationship)) {
      final resources = res.toMany[r.route.relationship]
          .map((id) => dao[id.type].fetchByIdAsResource(id.id));
      return r.collection(Collection(resources));
    }
    return r.notFound([ErrorObject(detail: 'Relationship not found')]);
  }

  @override
  Future fetchResource(FetchResource r) {
    if (!dao.containsKey(r.route.type)) {
      return r.notFound([ErrorObject(detail: 'Unknown resource type')]);
    }
    final res = dao[r.route.type].fetchByIdAsResource(r.route.id);
    if (res == null) {
      return r.notFound([ErrorObject(detail: 'Resource not found')]);
    }
    return r.resource(res);
  }

  @override
  Future fetchRelationship(FetchRelationship r) {
    if (!dao.containsKey(r.route.type)) {
      return r.notFound([ErrorObject(detail: 'Unknown resource type')]);
    }
    final res = dao[r.route.type].fetchByIdAsResource(r.route.id);
    if (res == null) {
      return r.notFound([ErrorObject(detail: 'Resource not found')]);
    }

    if (res.toOne.containsKey(r.route.relationship)) {
      final id = res.toOne[r.route.relationship];
      return r.toOne(id);
    }

    if (res.toMany.containsKey(r.route.relationship)) {
      final ids = res.toMany[r.route.relationship];
      return r.toMany(Collection(ids));
    }
    return r.notFound([ErrorObject(detail: 'Relationship not found')]);
  }

  @override
  Future deleteResource(DeleteResource r) {
    if (!dao.containsKey(r.route.type)) {
      return r.notFound([ErrorObject(detail: 'Unknown resource type')]);
    }
    final res = dao[r.route.type].fetchByIdAsResource(r.route.id);
    if (res == null) {
      return r.notFound([ErrorObject(detail: 'Resource not found')]);
    }
    final dependenciesCount = dao[r.route.type].deleteById(r.route.id);
    if (dependenciesCount == 0) {
      return r.noContent();
    }
    return r.meta({'dependenciesCount': dependenciesCount});
  }

  Future createResource(CreateResource r) async {
    if (!dao.containsKey(r.route.type)) {
      return r.notFound([ErrorObject(detail: 'Unknown resource type')]);
    }
    final resource = await r.resource();
    if (r.route.type != resource.type) {
      return r.conflict([ErrorObject(detail: 'Incompatible type')]);
    }

    Object obj;
    if (resource.hasId) {
      if (dao[r.route.type].fetchById(resource.id) != null) {
        return r.conflict([ErrorObject(detail: 'Resource already exists')]);
      }
      obj = dao[r.route.type].create(resource);
      dao[r.route.type].insert(obj);
      return r.noContent();
    } else {
      obj = dao[r.route.type].create(resource.replace(id: Uuid().v4()));
      dao[r.route.type].insert(obj);
      return r.created(dao[r.route.type].toResource(obj));
    }
  }

  @override
  Future updateResource(UpdateResource r) async {
    if (!dao.containsKey(r.route.type)) {
      return r.notFound([ErrorObject(detail: 'Unknown resource type')]);
    }
    final resource = await r.resource();
    if (r.route.type != resource.type) {
      return r.conflict([ErrorObject(detail: 'Incompatible type')]);
    }
    if (dao[r.route.type].fetchById(r.route.id) == null) {
      return r.notFound([ErrorObject(detail: 'Resource not found')]);
    }
    final updated = dao[r.route.type].update(r.route.id, resource);
    if (updated == null) {
      return r.noContent();
    }
    return r.updated(updated);
  }

  @override
  Future replaceRelationship(ReplaceRelationship r) async {
    if (!dao.containsKey(r.route.type)) {
      return r.notFound([ErrorObject(detail: 'Unknown resource type')]);
    }
    final rel = await r.relationship();
    if (rel is ToOne) {
      dao[r.route.type]
          .replaceToOne(r.route.id, r.route.relationship, rel.toIdentifier());
      return r.noContent();
    }
    if (rel is ToMany) {
      dao[r.route.type]
          .replaceToMany(r.route.id, r.route.relationship, rel.toIdentifiers());
      return r.noContent();
    }
  }

  @override
  Future addToRelationship(AddToRelationship r) async {
    if (!dao.containsKey(r.route.type)) {
      return r.notFound([ErrorObject(detail: 'Unknown resource type')]);
    }
    final rel = await r.relationship();
    final result = dao[r.route.type]
        .addToMany(r.route.id, r.route.relationship, rel.toIdentifiers());
    return r.toMany(Collection(result));
  }
}
