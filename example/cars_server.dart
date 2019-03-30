import 'dart:async';
import 'dart:io';

import 'package:json_api_server/json_api_server.dart';

import 'cars_server/controller.dart';
import 'cars_server/dao.dart';
import 'cars_server/model.dart';

void main() async {
  final addr = InternetAddress.loopbackIPv4;
  final port = 8080;
  await createServer(addr, port);
  print('Listening on ${addr.host}:$port');
}

Future<HttpServer> createServer(InternetAddress addr, int port) async {
  final models = ModelDAO();
  [
    Model('1')..name = 'Roadster',
    Model('2')..name = 'Model S',
    Model('3')..name = 'Model X',
    Model('4')..name = 'Model 3',
    Model('5')..name = 'X1',
    Model('6')..name = 'X3',
    Model('7')..name = 'X5',
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
    Company('4')..name = 'Toyota',
  ].forEach(companies.insert);

  final controller = CarsController({
    'companies': companies,
    'cities': cities,
    'models': models,
    'jobs': JobDAO()
  });

  final urlDesign = StandardURLDesign(Uri.parse('http://localhost:$port'));

  final jsonApiServer =
      JsonApiServer(urlDesign, controller, StandardDocumentBuilder(urlDesign));

  final httpServer = await HttpServer.bind(addr, port);

  httpServer.forEach(jsonApiServer.process);

  return httpServer;
}

class Url {
  static final _design = StandardURLDesign(Uri.parse('http://localhost:8080'));

  static Uri collection(String type) =>
      _design.collection(CollectionTarget(type));

  static Uri resource(String type, String id) =>
      _design.resource(ResourceTarget(type, id));

  static Uri related(String type, String id, String relationship) =>
      _design.related(RelatedTarget(type, id, relationship));

  static Uri relationship(String type, String id, String relationship) =>
      _design.relationship(RelationshipTarget(type, id, relationship));
}
