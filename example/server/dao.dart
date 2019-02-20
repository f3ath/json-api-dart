import 'package:json_api/core.dart';

import 'model.dart';

abstract class DAO<T extends HasId> {
  final collection = <String, T>{};

  int get length => collection.length;

  Resource toResource(T t);

  T fetchById(String id) => collection[id];

  void insert(T t) => collection[t.id] = t;

  Iterable<T> fetchCollection({int offset = 0, int limit = 1}) =>
      collection.values.skip(offset).take(limit);
}

class CarDAO extends DAO<Car> {
  Resource toResource(Car _) => Resource('cars', _.id, {'name': _.name});
}

class CityDAO extends DAO<City> {
  Resource toResource(City _) => Resource('cities', _.id, {'name': _.name});
}

class BrandDAO extends DAO<Brand> {
  Resource toResource(Brand brand) => Resource('brands', brand.id, {
        'name': brand.name
      }, toOne: {
        'headquarters': brand.headquarters == null
            ? null
            : Identifier('cities', brand.headquarters)
      }, toMany: {
        'models': brand.models.map((_) => Identifier('cars', _)).toList()
      });
}
