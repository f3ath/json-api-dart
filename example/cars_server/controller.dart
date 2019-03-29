import 'dart:async';
import 'dart:math';

import 'package:json_api_document/json_api_document.dart';
import 'package:json_api_server/json_api_server.dart';
import 'package:uuid/uuid.dart';

import 'dao.dart';
import 'job_queue.dart';

class CarsController implements JsonApiController {
  final Map<String, DAO> _dao;

  CarsController(this._dao);

  @override
  Future<void> fetchCollection(
      ControllerRequest<CollectionTarget, void> request,
      FetchCollectionResponse response) async {
    if (!_dao.containsKey(request.target.type)) {
      return response
          .errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    final page = NumberedPage.fromQueryParameters(request.uri.queryParameters,
        total: _dao[request.target.type].length);
    return response.sendCollection(Collection(
        _dao[request.target.type]
            .fetchCollection(offset: page.offset)
            .map(_dao[request.target.type].toResource),
        page: page));
  }

  @override
  Future<void> fetchRelated(ControllerRequest<RelatedTarget, void> request,
      FetchRelatedResponse response) async {
    if (!_dao.containsKey(request.target.type)) {
      return response
          .errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    final res =
        _dao[request.target.type].fetchByIdAsResource(request.target.id);
    if (res == null) {
      return response
          .errorNotFound([JsonApiError(detail: 'Resource not found')]);
    }

    if (res.toOne.containsKey(request.target.relationship)) {
      final id = res.toOne[request.target.relationship];
      final resource = _dao[id.type].fetchByIdAsResource(id.id);
      return response.sendResource(resource);
    }

    if (res.toMany.containsKey(request.target.relationship)) {
      final pageSize = 2;
      final totalPages =
          max(0, res.toMany[request.target.relationship].length - 1) ~/
                  pageSize +
              1;
      final page = NumberedPage.fromQueryParameters(request.uri.queryParameters,
          total: totalPages);
      final resources = res.toMany[request.target.relationship]
          .skip(page.offset * pageSize)
          .take(pageSize)
          .map((id) => _dao[id.type].fetchByIdAsResource(id.id));
      return response.sendCollection(Collection(resources, page: page));
    }
    return response
        .errorNotFound([JsonApiError(detail: 'Relationship not found')]);
  }

  @override
  Future<void> fetchResource(ControllerRequest<ResourceTarget, void> request,
      FetchResourceResponse response) async {
    if (!_dao.containsKey(request.target.type)) {
      return response
          .errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    final obj = _dao[request.target.type].fetchById(request.target.id);

    if (obj == null) {
      return response
          .errorNotFound([JsonApiError(detail: 'Resource not found')]);
    }
    if (obj is Job && obj.resource != null) {
      return response.sendSeeOther(obj.resource);
    }

    final fetchById = (Identifier _) => _dao[_.type].fetchByIdAsResource(_.id);

    final res = _dao[request.target.type].toResource(obj);
    final children = res.toOne.values
        .map(fetchById)
        .followedBy(res.toMany.values.expand((_) => _.map(fetchById)));

    return response.sendResource(res, included: children);
  }

  @override
  Future<void> fetchRelationship(
      ControllerRequest<RelationshipTarget, void> request,
      FetchRelationshipResponse response) async {
    if (!_dao.containsKey(request.target.type)) {
      return response
          .errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    final res =
        _dao[request.target.type].fetchByIdAsResource(request.target.id);
    if (res == null) {
      return response
          .errorNotFound([JsonApiError(detail: 'Resource not found')]);
    }

    if (res.toOne.containsKey(request.target.relationship)) {
      final id = res.toOne[request.target.relationship];
      return response.sendToOne(id);
    }

    if (res.toMany.containsKey(request.target.relationship)) {
      final ids = res.toMany[request.target.relationship];
      return response.sendToMany(ids);
    }
    return response
        .errorNotFound([JsonApiError(detail: 'Relationship not found')]);
  }

  @override
  Future<void> deleteResource(ControllerRequest<ResourceTarget, void> request,
      DeleteResourceResponse response) async {
    if (!_dao.containsKey(request.target.type)) {
      return response
          .errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    final res =
        _dao[request.target.type].fetchByIdAsResource(request.target.id);
    if (res == null) {
      return response
          .errorNotFound([JsonApiError(detail: 'Resource not found')]);
    }
    final dependenciesCount =
        _dao[request.target.type].deleteById(request.target.id);
    if (dependenciesCount == 0) {
      return response.sendNoContent();
    }
    return response.sendMeta({'dependenciesCount': dependenciesCount});
  }

  @override
  Future<void> createResource(
      ControllerRequest<CollectionTarget, Resource> request,
      CreateResourceResponse response) async {
    if (!_dao.containsKey(request.target.type)) {
      return response
          .errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    if (request.target.type != request.payload.type) {
      return response
          .errorConflict([JsonApiError(detail: 'Incompatible type')]);
    }

    if (request.payload.hasId) {
      if (_dao[request.target.type].fetchById(request.payload.id) != null) {
        return response
            .errorConflict([JsonApiError(detail: 'Resource already exists')]);
      }
      final created = _dao[request.target.type].create(request.payload);
      _dao[request.target.type].insert(created);
      return response.sendNoContent();
    }

    final created = _dao[request.target.type].create(Resource(
        request.payload.type, Uuid().v4(),
        attributes: request.payload.attributes,
        toMany: request.payload.toMany,
        toOne: request.payload.toOne));

    if (request.target.type == 'models') {
      // Insertion is artificially delayed
      final job = Job(Future.delayed(Duration(milliseconds: 100), () {
        _dao[request.target.type].insert(created);
        return _dao[request.target.type].toResource(created);
      }));
      _dao['jobs'].insert(job);
      return response.sendAccepted(_dao['jobs'].toResource(job));
    }

    _dao[request.target.type].insert(created);

    return response.sendCreated(_dao[request.target.type].toResource(created));
  }

  @override
  Future<void> updateResource(
      ControllerRequest<ResourceTarget, Resource> request,
      UpdateResourceResponse response) async {
    if (!_dao.containsKey(request.target.type)) {
      return response
          .errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    if (request.target.type != request.payload.type) {
      return response
          .errorConflict([JsonApiError(detail: 'Incompatible type')]);
    }
    if (_dao[request.target.type].fetchById(request.target.id) == null) {
      return response
          .errorNotFound([JsonApiError(detail: 'Resource not found')]);
    }
    final updated =
        _dao[request.target.type].update(request.target.id, request.payload);
    if (updated == null) {
      return response.sendNoContent();
    }
    return response.sendUpdated(updated);
  }

  @override
  Future<void> replaceToOne(
      ControllerRequest<RelationshipTarget, Identifier> request,
      ReplaceToOneResponse response) async {
    if (!_dao.containsKey(request.target.type)) {
      return response
          .errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    _dao[request.target.type].replaceToOne(
        request.target.id, request.target.relationship, request.payload);
    return response.sendNoContent();
  }

  @override
  Future<void> replaceToMany(
      ControllerRequest<RelationshipTarget, Iterable<Identifier>> request,
      ReplaceToManyResponse response) async {
    if (!_dao.containsKey(request.target.type)) {
      return response
          .errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    _dao[request.target.type].replaceToMany(
        request.target.id, request.target.relationship, request.payload);
    return response.sendNoContent();
  }

  @override
  Future<void> addToMany(
      ControllerRequest<RelationshipTarget, Iterable<Identifier>> request,
      AddToManyResponse response) async {
    if (!_dao.containsKey(request.target.type)) {
      return response
          .errorNotFound([JsonApiError(detail: 'Unknown resource type')]);
    }
    final result = _dao[request.target.type].addToMany(
        request.target.id, request.target.relationship, request.payload);
    return response.sendToMany(result);
  }
}
