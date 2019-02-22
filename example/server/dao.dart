import 'package:json_api/resource.dart';

import 'model.dart';

abstract class DAO<T extends HasId> {
  final collection = <String, T>{};

  int get length => collection.length;

  Resource toResource(T t);

  T fetchById(String id) => collection[id];

  void insert(T t) => collection[t.id] = t;

  Iterable<T> fetchCollection({int offset = 0, int limit = 1}) =>
      collection.values.skip(offset).take(limit);

  T fromResource(Resource resource);

  void addToMany(String id, String rel, Iterable<Identifier> ids) {
    throw UnimplementedError();
  }
}

class CarDAO extends DAO<Car> {
  Resource toResource(Car _) =>
      Resource('cars', _.id, attributes: {'name': _.name});

  @override
  Car fromResource(Resource r) => Car(r.id, r.attributes['name']);
}

class CityDAO extends DAO<City> {
  Resource toResource(City _) =>
      Resource('cities', _.id, attributes: {'name': _.name});

  @override
  City fromResource(Resource r) => City(r.id, r.attributes['name']);
}

class BrandDAO extends DAO<Brand> {
  Resource toResource(Brand brand) => Resource('brands', brand.id, attributes: {
        'name': brand.name
      }, toOne: {
        'headquarters': brand.headquarters == null
            ? null
            : Identifier('cities', brand.headquarters)
      }, toMany: {
        'models': brand.models.map((_) => Identifier('cars', _)).toList()
      });

  @override
  Brand fromResource(Resource r) => Brand(r.id, r.attributes['name']);

  @override
  void addToMany(String id, String rel, Iterable<Identifier> ids) {
    final brand = fetchById(id);
    switch (rel) {
      case 'models':
        ids.forEach((id) {
          if (id.type != 'cars') throw 'Invalid type';
          brand.models.add(id.id);
        });
        break;

      default:
        throw ArgumentError.value(rel, 'rel');
    }
  }
}
