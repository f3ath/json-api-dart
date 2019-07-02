import 'dart:async';
import 'dart:io';

import 'package:json_api/src/routing/path_based_url_design.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/server_document_builder.dart';

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

  final httpServer = await HttpServer.bind(addr, port);
  final routing = PathBasedUrlDesign(Uri.parse('http://localhost:$port'));
  final pagination = FixedSizePage(1);
  final documentBuilder = ServerDocumentBuilder(routing, pagination);
  final jsonApiServer = Server(routing, controller, documentBuilder);

  httpServer.forEach(jsonApiServer.process);
  return httpServer;
}
