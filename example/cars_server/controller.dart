import 'dart:async';

import 'package:json_api/src/identifier.dart';
import 'package:json_api/src/resource.dart';
import 'package:json_api/src/server/numbered_page.dart';
import 'package:json_api/src/server/resource_controller.dart';
import 'package:uuid/uuid.dart';

import 'dao.dart';

class CarsController implements ResourceController {
  final Map<String, DAO> dao;

  CarsController(this.dao);

  @override
  bool supports(String type) => dao.containsKey(type);

  Future<Collection<Resource>> fetchCollection(
      String type, Map<String, String> params) async {
    final page =
        NumberedPage.fromQueryParameters(params, total: dao[type].length);
    return Collection(
        dao[type]
            .fetchCollection(offset: page.number - 1)
            .map(dao[type].toResource),
        page: page);
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
      String type, Resource resource, Map<String, String> params) async {
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
  Future<void> deleteResource(String type, String id, Map<String, String> params) {
    if (dao[type].fetchById(id) == null) {
      throw ResourceControllerException(404, detail: 'Resource not found');
    }
    dao[type].deleteById(id);
    return null;
  }
}
