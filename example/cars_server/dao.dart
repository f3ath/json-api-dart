import 'package:json_api/src/identifier.dart';
import 'package:json_api/src/resource.dart';

import 'model.dart';

abstract class DAO<T> {
  final _collection = <String, T>{};

  int get length => _collection.length;

  Resource toResource(T t);

  T create(Resource resource);

  T fetchById(String id) => _collection[id];

  void insert(T t); // => collection[t.id] = t;

  Iterable<T> fetchCollection({int offset = 0, int limit = 1}) =>
      _collection.values.skip(offset).take(limit);
}

class ModelDAO extends DAO<Model> {
  Resource toResource(Model _) =>
      Resource('models', _.id, attributes: {'name': _.name});

  void insert(Model model) => _collection[model.id] = model;

  Model create(Resource r) {
    return Model(r.id, r.attributes['name']);
  }
}

class CityDAO extends DAO<City> {
  Resource toResource(City _) =>
      Resource('cities', _.id, attributes: {'name': _.name});

  void insert(City city) => _collection[city.id] = city;

  City create(Resource r) {
    return City(r.id, r.attributes['name']);
  }
}

class CompanyDAO extends DAO<Company> {
  Resource toResource(Company company) =>
      Resource('companies', company.id, attributes: {
        'name': company.name
      }, toOne: {
        'hq': company.headquarters == null
            ? null
            : Identifier('cities', company.headquarters)
      }, toMany: {
        'models': company.models.map((_) => Identifier('models', _)).toList()
      });

  void insert(Company company) => _collection[company.id] = company;

  Company create(Resource r) {
    return Company(r.id, r.attributes['name']);
  }
}
