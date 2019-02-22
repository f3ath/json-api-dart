import 'package:json_api/resource.dart';
import 'package:json_api/server.dart';

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
      yield obj == null ? null : dao[id.type].toResource(obj);
    }
  }

  @override
  Future<void> createResource(Resource resource) async {
    final obj = dao[resource.type].fromResource(resource);
    dao[resource.type].insert(obj);
  }

  @override
  Future<void> mergeToMany(Identifier r, String rel, Iterable<Identifier> ids) async {
    dao[r.type].addToMany(r.id, rel, ids);
  }
}
