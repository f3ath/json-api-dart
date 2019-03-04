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
    Model('1')..name = 'Roadster',
    Model('2')..name = 'Model S',
    Model('3')..name = 'Model X',
    Model('4')..name = 'Model 3',
  ].forEach(models.insert);

  final cities = CityDAO();
  [
    City('1')..name = 'Munich',
    City('2')..name = 'Palo Alto',
    City('3')..name = 'Ingolstadt',
  ].forEach(cities.insert);

  final companies = CompanyDAO();
  [
    Company('1')
      ..name = 'Tesla'
      ..headquarters = '2'
      ..models.addAll(['1', '2', '3', '4']),
    Company('2')
      ..name = 'BMW'
      ..headquarters = '1',
    Company('3')..name = 'Audi',
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
