import 'dart:async';

import 'package:json_api/json_api.dart';
import 'package:json_api/src/server/_server.dart';
import 'package:uuid/uuid.dart';

import 'dao.dart';
import 'job_queue.dart';

class CarsController implements Controller {
  final Map<String, DAO> _dao;
  final PageFactory _page;

  CarsController(this._dao, this._page);

  @override
  void fetchCollection(
      FetchCollection request, Map<String, List<String>> query) {
    final dao = _getDao(request);
    final page = _page(query);
    final collection = dao.fetchCollection(page);
    request.sendCollection(collection.map(dao.toResource), page: page);
  }

  @override
  void fetchRelated(FetchRelated request, Map<String, List<String>> query) {
    final dao = _getDao(request);

    final res = dao.fetchByIdAsResource(request.target.id);
    if (res == null) {
      request.errorNotFound([JsonApiError(detail: 'Resource not found')]);
      return;
    }

    if (res.toOne.containsKey(request.target.relationship)) {
      final id = res.toOne[request.target.relationship];
      final resource = _dao[id.type].fetchByIdAsResource(id.id);
      request.sendResource(resource);
      return;
    }

    if (res.toMany.containsKey(request.target.relationship)) {
      final page = _page(query);
      final relationships = res.toMany[request.target.relationship];
      final resources = relationships
          .skip(page.offset)
          .take(page.limit)
          .map((id) => _dao[id.type].fetchByIdAsResource(id.id));
      request.sendCollection(Collection(resources, total: relationships.length),
          page: page);
      return;
    }
    request.errorNotFound([JsonApiError(detail: 'Relationship not found')]);
  }

  @override
  void fetchResource(FetchResource request, Map<String, List<String>> query) {
    final dao = _getDao(request);

    final obj = dao.fetchById(request.target.id);

    if (obj == null) {
      request.errorNotFound([JsonApiError(detail: 'Resource not found')]);
      return;
    }
    if (obj is Job && obj.resource != null) {
      request.sendSeeOther(obj.resource);
      return;
    }

    final fetchById = (Identifier _) => _dao[_.type].fetchByIdAsResource(_.id);

    final res = dao.toResource(obj);
    final children = res.toOne.values
        .map(fetchById)
        .followedBy(res.toMany.values.expand((_) => _.map(fetchById)));

    request.sendResource(res, included: children);
  }

  @override
  void fetchRelationship(
      FetchRelationship request, Map<String, List<String>> query) {
    final dao = _getDao(request);

    final res = dao.fetchByIdAsResource(request.target.id);
    if (res == null) {
      request.errorNotFound([JsonApiError(detail: 'Resource not found')]);
      return;
    }

    if (res.toOne.containsKey(request.target.relationship)) {
      final id = res.toOne[request.target.relationship];
      request.sendToOne(id);
      return;
    }

    if (res.toMany.containsKey(request.target.relationship)) {
      final ids = res.toMany[request.target.relationship];
      request.sendToMany(ids);
      return;
    }
    request.errorNotFound([JsonApiError(detail: 'Relationship not found')]);
  }

  @override
  void deleteResource(DeleteResource request) {
    final dao = _getDao(request);

    final res = dao.fetchByIdAsResource(request.target.id);
    if (res == null) {
      request.errorNotFound([JsonApiError(detail: 'Resource not found')]);
      return;
    }
    final dependenciesCount = dao.deleteById(request.target.id);
    if (dependenciesCount == 0) {
      request.sendNoContent();
      return;
    }
    request.sendMeta({'dependenciesCount': dependenciesCount});
  }

  @override
  void createResource(CreateResource request, Resource resource) {
    final dao = _getDao(request);

    if (request.target.type != resource.type) {
      request.errorConflict([JsonApiError(detail: 'Incompatible type')]);
      return;
    }

    if (resource.id != null) {
      if (dao.fetchById(resource.id) != null) {
        request
            .errorConflict([JsonApiError(detail: 'Resource already exists')]);
        return;
      }
      final created = dao.create(resource);
      dao.insert(created);
      request.sendNoContent();
      return;
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
      request.sendAccepted(_dao['jobs'].toResource(job));
      return;
    }

    dao.insert(created);

    request.sendCreated(dao.toResource(created));
  }

  @override
  void updateResource(UpdateResource request, Resource resource) {
    final dao = _getDao(request);

    if (request.target.type != resource.type) {
      request.errorConflict([JsonApiError(detail: 'Incompatible type')]);
      return;
    }
    if (dao.fetchById(request.target.id) == null) {
      request.errorNotFound([JsonApiError(detail: 'Resource not found')]);
      return;
    }
    final updated = dao.update(request.target.id, resource);
    if (updated == null) {
      request.sendNoContent();
      return;
    }
    request.sendUpdated(updated);
  }

  @override
  void replaceToOne(UpdateRelationship request, Identifier identifier) {
    final dao = _getDao(request);

    dao.replaceToOne(
        request.target.id, request.target.relationship, identifier);
    request.sendNoContent();
  }

  @override
  void replaceToMany(UpdateRelationship request, List<Identifier> identifiers) {
    final dao = _getDao(request);

    dao.replaceToMany(
        request.target.id, request.target.relationship, identifiers);
    request.sendNoContent();
  }

  DAO _getDao(Request request) => _dao[request.target.type];

  @override
  void addToMany(AddToMany request, List<Identifier> identifiers) {
    final dao = _getDao(request);

    request.sendToMany(dao.addToMany(
        request.target.id, request.target.relationship, identifiers));
  }

  @override
  bool supportsType(String type) => _dao.containsKey(type);
}
