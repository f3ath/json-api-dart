import 'package:json_api/document.dart';

import 'model.dart';

abstract class DAO<T extends HasId> {
  final collection = <String, T>{};

  int get length => collection.length;

  Resource toResource(T t);

  Relationship relationship(String name, T t) {
    throw ArgumentError();
  }

  Map<String, Relationship> relationships(List<String> names, T t) =>
      Map.fromIterables(names, names.map((_) => relationship(_, t)));

  T fetchById(String id) => collection[id];

  void insert(T t) => collection[t.id] = t;

  Iterable<T> fetchCollection({int offset = 0, int limit = 1}) =>
      collection.values.skip(offset).take(limit);

  HasId fromResource(Resource r);

  addRelationship(T t, String name, HasId related) {}
}

class CarDAO extends DAO<Car> {
  Resource toResource(Car _) =>
      Resource('cars', _.id, attributes: {'name': _.name});

  @override
  HasId fromResource(Resource r) => Car(r.id, r.attributes['name']);
}

class CityDAO extends DAO<City> {
  Resource toResource(City _) =>
      Resource('cities', _.id, attributes: {'name': _.name});

  @override
  HasId fromResource(Resource r) => City(r.id, r.attributes['name']);
}

class BrandDAO extends DAO<Brand> {
  Resource toResource(Brand brand) => Resource('brands', brand.id,
      attributes: {'name': brand.name},
      relationships: relationships(['headquarters', 'models'], brand));

  Relationship relationship(String name, Brand brand) {
    switch (name) {
      case 'headquarters':
        return ToOne(brand.headquarters == null
            ? null
            : Identifier('cities', brand.headquarters));
      case 'models':
        return ToMany(brand.models.map((_) => Identifier('cars', _)));
    }
    throw ArgumentError();
  }

  @override
  HasId fromResource(Resource r) => Brand(r.id, r.attributes['name']);

  @override
  addRelationship(Brand obj, String name, HasId related) {
    switch (name) {
      case 'models':
        obj.models.add(related.id);
        break;
      default:
        throw ArgumentError.value(name, 'name');
    }
  }
}
