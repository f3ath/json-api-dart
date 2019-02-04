import 'package:json_api/simple_server.dart';

import 'controller.dart';
import 'dao.dart';
import 'model.dart';

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

  final controller =
      CarsController({'brands': brands, 'cities': cities, 'cars': cars});

  return SimpleServer(controller);
}
