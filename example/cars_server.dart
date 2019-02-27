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

  return SimpleServer(
      CarsController({'brands': brands, 'cities': cities, 'cars': cars}));
}
