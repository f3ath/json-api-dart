import 'package:json_api/document.dart';
import 'package:json_api/server.dart';

import 'dao.dart';

class CarsController implements ResourceController {
  final Map<String, DAO> dao;

  CarsController(this.dao);

  @override
  bool supports(String type) => dao.containsKey(type);

  Future<Collection<Resource>> fetchCollection(
      String type, Map<String, String> queryParameters) async {
    final page = NumberedPage.fromQueryParameters(queryParameters,
        total: dao[type].length);
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
  Future createResource(String type, Resource resource) async {
    final obj = dao[type].fromResource(resource);
    dao[type].insert(obj);
    return null;
  }

  @override
  Future mergeToMany(Identifier id, String name, ToMany rel) async {
    final obj = dao[id.type].fetchById(id.id);
    rel.identifiers
        .map((id) => dao[id.type].fetchById(id.id))
        .forEach((related) => dao[id.type].addRelationship(obj, name, related));

    return null;
  }
}
