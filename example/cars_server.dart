import 'dart:io';

import 'package:json_api/src/server/simple_server.dart';

import 'cars_server/controller.dart';
import 'cars_server/dao.dart';
import 'cars_server/model.dart';

void main() async {
  final addr = InternetAddress.loopbackIPv4;
  final port = 8080;
  await createServer().start(addr, port);
  print('Listening on ${addr.host}:$port');
}

SimpleServer createServer() {
  final models = ModelDAO();
  [
    Model('1', 'Roadster'),
    Model('2', 'Model S'),
    Model('3', 'Model X'),
    Model('4', 'Model 3'),
  ].forEach(models.insert);

  final cities = CityDAO();
  [
    City('1', 'Munich'),
    City('2', 'Palo Alto'),
    City('3', 'Ingolstadt'),
  ].forEach(cities.insert);

  final companies = CompanyDAO();
  [
    Company('1', 'Tesla', headquarters: '2', models: ['1', '2', '3', '4']),
    Company('2', 'BMW', headquarters: '1'),
    Company('3', 'Audi'),
  ].forEach(companies.insert);

  return SimpleServer(CarsController(
      {'companies': companies, 'cities': cities, 'models': models}));
}

class Url {
  static final _base = Uri.parse('http://localhost:8080');

  static collection(String type) => _base.replace(path: '/$type');

  static resource(String type, String id) => _base.replace(path: '/$type/$id');

  static related(String type, String id, String rel) =>
      _base.replace(path: '/$type/$id/$rel');

  static relationship(String type, String id, String rel) =>
      _base.replace(path: '/$type/$id/relationships/$rel');
}
