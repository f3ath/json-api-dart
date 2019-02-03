import 'dart:io';

import 'package:json_api/document.dart';
import 'package:json_api/server.dart';

class TestServer {
  HttpServer httpServer;

  Future start(InternetAddress addr, int port) async {
    final cars = CarDAO();
    [
      Car('1', 'Roadster'),
      Car('2', 'Model S'),
      Car('3', 'Model X'),
      Car('4', 'Model 3'),
    ].forEach(cars.insert);

    final cities = CityDAO();
    [
      City('1', 'Munich'),
      City('2', 'Palo Alto'),
      City('3', 'Ingolstadt'),
    ].forEach(cities.insert);

    final brands = BrandDAO();
    [
      Brand('1', 'Tesla', headquarters: '2', models: ['1', '2', '3', '4']),
      Brand('2', 'BMW', headquarters: '1'),
      Brand('3', 'Audi', headquarters: '3'),
      Brand('4', 'Ford'),
      Brand('5', 'Toyota')
    ].forEach(brands.insert);

    final jsonApiServer = JsonApiServer<HttpRequest>(
        TestController({'brands': brands, 'cities': cities, 'cars': cars}),
        resolveAction,
        StandardLinks(Uri.parse('http://localhost:8080')));

    httpServer = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      8080,
    );

    httpServer.forEach((rq) async {
      final rs = await jsonApiServer.handle(rq);
      rq.response
        ..statusCode = rs.status
        ..write(rs.body)
        ..close();
    });
  }

  Future stop() => httpServer.close();
}

JsonApiRequest resolveAction(HttpRequest rq) {
  final seg = rq.uri.pathSegments;
  switch (seg.length) {
    case 1:
      return CollectionRequest(seg[0], queryParameters: rq.uri.queryParameters);
    case 2:
      return ResourceRequest(seg[0], seg[1]);
    case 3:
      return RelatedRequest(seg[0], seg[1], seg[2]);
    case 4:
      if (seg[2] == 'relationships') {
        return RelationshipRequest(seg[0], seg[1], seg[3]);
      }
  }
  return null;
}

class TestController implements ResourceController {
  final Map<String, DAO> daos;

  TestController(this.daos);

  Future<Collection<Resource>> fetchCollection(
      String type, Map<String, String> queryParameters) async {
    final page = NumberedPage.fromQueryParameters(queryParameters,
        total: daos[type].length);
    return Collection(
        daos[type]
            .fetchCollection(offset: page.number - 1)
            .map(daos[type].toResource),
        page: page);
  }

  @override
  Stream<Resource> fetchResources(Iterable<Identifier> ids) async* {
    for (final id in ids)
      yield daos[id.type].toResource(daos[id.type].fetchById(id.id));
  }

  @override
  bool supports(String type) => daos.containsKey(type);
}

abstract class HasId {
  String get id;
}

abstract class DAO<T extends HasId> {
  final collection = <String, T>{};

  int get length => collection.length;

  Resource toResource(T t);

  Relationship relationship(String name, T t) {
    throw ArgumentError();
  }

  Map<String, Relationship> relationships(List<String> names, T t) =>
      Map.fromIterables(names, names.map((_) => relationship(_, t)));

  //  T fromResource(Resource r);

  T fetchById(String id) => collection[id];

  void insert(T t) => collection[t.id] = t;

  Iterable<T> fetchCollection({int offset = 0, int limit = 1}) =>
      collection.values.skip(offset).take(limit);
}

class Brand implements HasId {
  final String name;
  final String id;
  final String headquarters;
  final List<String> models;

  Brand(this.id, this.name, {this.headquarters, this.models = const []});
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
}

class City implements HasId {
  final String name;
  final String id;

  City(this.id, this.name);
}

class CityDAO extends DAO<City> {
  Resource toResource(City _) =>
      Resource('cities', _.id, attributes: {'name': _.name});
}

class Car implements HasId {
  final String name;
  final String id;

  Car(this.id, this.name);
}

class CarDAO extends DAO<Car> {
  Resource toResource(Car _) =>
      Resource('cars', _.id, attributes: {'name': _.name});
}
