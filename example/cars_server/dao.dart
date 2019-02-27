import 'package:json_api/src/identifier.dart';
import 'package:json_api/src/resource.dart';

import 'model.dart';

abstract class DAO<T> {
  final _collection = <String, T>{};

  int get length => _collection.length;

  Resource toResource(T t);

  T fetchById(String id) => _collection[id];

  void insert(T t); // => collection[t.id] = t;

  Iterable<T> fetchCollection({int offset = 0, int limit = 1}) =>
      _collection.values.skip(offset).take(limit);
}

class CarDAO extends DAO<Car> {
  Resource toResource(Car _) =>
      Resource('cars', _.id, attributes: {'name': _.name});

  void insert(Car car) => _collection[car.id] = car;
}

class CityDAO extends DAO<City> {
  Resource toResource(City _) =>
      Resource('cities', _.id, attributes: {'name': _.name});

  void insert(City city) => _collection[city.id] = city;
}

class BrandDAO extends DAO<Brand> {
  Resource toResource(Brand brand) => Resource('brands', brand.id, attributes: {
        'name': brand.name
      }, toOne: {
        'hq': brand.headquarters == null
            ? null
            : Identifier('cities', brand.headquarters)
      }, toMany: {
        'models': brand.models.map((_) => Identifier('cars', _)).toList()
      });

  void insert(Brand brand) => _collection[brand.id] = brand;
}
