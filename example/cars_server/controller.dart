import 'dart:async';

import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/server/numbered_page.dart';
import 'package:json_api/src/server/request.dart';
import 'package:json_api/src/server/resource_controller.dart';
import 'package:uuid/uuid.dart';

import 'dao.dart';

class CarsController implements ResourceController {
  final Map<String, DAO> dao;

  CarsController(this.dao);

  @override
  bool supports(String type) => dao.containsKey(type);

  Future<OperationResult<Collection<Resource>>> fetchCollection(
      String type, JsonApiHttpRequest request) async {
    final page = NumberedPage.fromQueryParameters(request.uri.queryParameters,
        total: dao[type].length);
    return OperationResult.ok(Collection(
        dao[type]
            .fetchCollection(offset: page.number - 1)
            .map(dao[type].toResource),
        page: page));
  }

  @override
  Stream<Resource> fetchResources(Iterable<Identifier> ids) async* {
    for (final id in ids) {
      final obj = dao[id.type].fetchById(id.id);
      if (obj == null) {
        throw ResourceControllerException(404, detail: 'Resource not found');
      }
      yield dao[id.type].toResource(obj);
    }
  }

  @override
  Future<Resource> createResource(
      String type, Resource resource, JsonApiHttpRequest request) async {
    if (type != resource.type) {
      throw ResourceControllerException(409, detail: 'Incompatible type');
    }
    Object obj;
    if (resource.hasId) {
      if (dao[type].fetchById(resource.id) != null) {
        throw ResourceControllerException(409,
            detail: 'Resource already exists');
      }
      obj = dao[type].create(resource);
    } else {
      obj = dao[type].create(resource.replace(id: Uuid().v4()));
    }
    dao[type].insert(obj);
    return dao[type].toResource(obj);
  }

  @override
  Future<Map<String, Object>> deleteResource(
      String type, String id, JsonApiHttpRequest request) async {
    if (dao[type].fetchById(id) == null) {
      throw ResourceControllerException(404, detail: 'Resource not found');
    }
    final deps = dao[type].deleteById(id);
    if (deps > 0) {
      return {'deps': deps};
    }
    return null;
  }

  @override
  Future<Resource> updateResource(String type, String id, Resource resource,
      JsonApiHttpRequest request) async {
    if (dao[type].fetchById(id) == null) {
      throw ResourceControllerException(404, detail: 'Resource not found');
    }
    return dao[type].update(id, resource);
  }
}
