import 'dart:async';

import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/json_api_error.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/server/_server.dart';
import 'package:uuid/uuid.dart';

import 'dao.dart';
import 'job_queue.dart';

class CarsController implements Controller {
  final Map<String, DAO> _dao;
  final PageFactory _page;

  CarsController(this._dao, this._page);

  @override
  Response fetchCollection(
      FetchCollection request, Map<String, List<String>> query) {
    final dao = _getDao(request);
    final page = _page(query);
    final collection = dao.fetchCollection(page);
    return request.sendCollection(collection.map(dao.toResource), page: page);
  }

  @override
  Response fetchRelated(FetchRelated request, Map<String, List<String>> query) {
    final dao = _getDao(request);

    final res = dao.fetchByIdAsResource(request.target.id);
    if (res == null) {
      return request
          .errorNotFound([JsonApiError(detail: 'Resource not found')]);
    }

    if (res.toOne.containsKey(request.target.relationship)) {
      final id = res.toOne[request.target.relationship];
      final resource = _dao[id.type].fetchByIdAsResource(id.id);
      return request.sendResource(resource);
    }

    if (res.toMany.containsKey(request.target.relationship)) {
      final page = _page(query);
      final relationships = res.toMany[request.target.relationship];
      final resources = relationships
          .skip(page.offset)
          .take(page.limit)
          .map((id) => _dao[id.type].fetchByIdAsResource(id.id));
      return request.sendCollection(
          Collection(resources, total: relationships.length),
          page: page);
    }
    return request
        .errorNotFound([JsonApiError(detail: 'Relationship not found')]);
  }

  @override
  Response fetchResource(
      FetchResource request, Map<String, List<String>> query) {
    final dao = _getDao(request);

    final obj = dao.fetchById(request.target.id);

    if (obj == null) {
      return request
          .errorNotFound([JsonApiError(detail: 'Resource not found')]);
    }
    if (obj is Job && obj.resource != null) {
      return request.sendSeeOther(obj.resource);
    }

    final fetchById = (Identifier _) => _dao[_.type].fetchByIdAsResource(_.id);

    final res = dao.toResource(obj);
    final children = res.toOne.values
        .map(fetchById)
        .followedBy(res.toMany.values.expand((_) => _.map(fetchById)));

    return request.sendResource(res, included: children);
  }

  @override
  Response fetchRelationship(
      FetchRelationship request, Map<String, List<String>> query) {
    final dao = _getDao(request);

    final res = dao.fetchByIdAsResource(request.target.id);
    if (res == null) {
      return request
          .errorNotFound([JsonApiError(detail: 'Resource not found')]);
    }

    if (res.toOne.containsKey(request.target.relationship)) {
      final id = res.toOne[request.target.relationship];
      return request.sendToOne(id);
    }

    if (res.toMany.containsKey(request.target.relationship)) {
      final ids = res.toMany[request.target.relationship];
      return request.sendToMany(ids);
    }
    return request
        .errorNotFound([JsonApiError(detail: 'Relationship not found')]);
  }

  @override
  Response deleteResource(DeleteResource request) {
    final dao = _getDao(request);

    final res = dao.fetchByIdAsResource(request.target.id);
    if (res == null) {
      return request
          .errorNotFound([JsonApiError(detail: 'Resource not found')]);
    }
    final dependenciesCount = dao.deleteById(request.target.id);
    if (dependenciesCount == 0) {
      return request.sendNoContent();
    }
    return request.sendMeta({'dependenciesCount': dependenciesCount});
  }

  @override
  Response createResource(CreateResource request, Resource resource) {
    final dao = _getDao(request);

    if (request.target.type != resource.type) {
      return request.errorConflict([JsonApiError(detail: 'Incompatible type')]);
    }

    if (resource.id != null) {
      if (dao.fetchById(resource.id) != null) {
        return request
            .errorConflict([JsonApiError(detail: 'Resource already exists')]);
      }
      final created = dao.create(resource);
      dao.insert(created);
      return request.sendNoContent();
    }

    final created = dao.create(Resource(resource.type, Uuid().v4(),
        attributes: resource.attributes,
        toMany: resource.toMany,
        toOne: resource.toOne));

    if (request.target.type == 'models') {
      // Insertion is artificially delayed
      final job = Job(Future.delayed(Duration(milliseconds: 100), () {
        dao.insert(created);
        return dao.toResource(created);
      }));
      _dao['jobs'].insert(job);
      return request.sendAccepted(_dao['jobs'].toResource(job));
    }

    dao.insert(created);

    return request.sendCreated(dao.toResource(created));
  }

  @override
  Response updateResource(UpdateResource request, Resource resource) {
    final dao = _getDao(request);

    if (request.target.type != resource.type) {
      return request.errorConflict([JsonApiError(detail: 'Incompatible type')]);
    }
    if (dao.fetchById(request.target.id) == null) {
      return request
          .errorNotFound([JsonApiError(detail: 'Resource not found')]);
    }
    final updated = dao.update(request.target.id, resource);
    if (updated == null) {
      return request.sendNoContent();
    }
    return request.sendUpdated(updated);
  }

  @override
  Response replaceToOne(UpdateRelationship request, Identifier identifier) {
    final dao = _getDao(request);

    dao.replaceToOne(
        request.target.id, request.target.relationship, identifier);
    return request.sendNoContent();
  }

  @override
  Response replaceToMany(
      UpdateRelationship request, List<Identifier> identifiers) {
    final dao = _getDao(request);

    dao.replaceToMany(
        request.target.id, request.target.relationship, identifiers);
    return request.sendNoContent();
  }

  DAO _getDao(Request request) => _dao[request.target.type];

  @override
  Response addToMany(AddToMany request, List<Identifier> identifiers) {
    final dao = _getDao(request);

    return request.sendToMany(dao.addToMany(
        request.target.id, request.target.relationship, identifiers));
  }

  @override
  bool supportsType(String type) => _dao.containsKey(type);
}
