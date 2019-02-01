import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:json_api/document.dart';
import 'package:json_api/server.dart';

Future main() async {
  var server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    8080,
  );
  print('Listening on localhost:${server.port}');

  server.forEach((rq) async {
    try {
      final doc = await routing
          .resolveOperation(rq.uri, rq.method)
          .handler(controller);
      rq.response
        ..headers.contentType = ContentType('application', 'vnd.api+json')
        ..write(json.encode(doc))
        ..close();
    } catch (e) {
      print(e);
      rq.response
        ..statusCode = 500
        ..close();
    }
  });
}

final routing = RecommendedRouting(Uri.parse('http://localhost:8080'));
final resourceController = ExampleResourceController();
final controller = DocumentController(routing, resourceController);

class ExampleResourceController implements ResourceController<HttpRequest> {
  FutureOr<Collection<Resource>> fetchCollection(JsonApiRequest<HttpRequest> rq) {
    switch (type) {
      case 'countries':
        return Collection(countries.map((_) => Resource(
                type, _.id.toString(), attributes: {
              'name': _.name
            }, relationships: {
              'president': ToOne(Identifier('people', _.president.toString()))
            })));
    }
    return Collection([]);
  }
}

class Country {
  final int id;
  final String name;
  int president;

  Country(this.id, this.name);
}

class Person {
  final int id;
  final String name;

  Person(this.id, this.name);
}

final countries = [
  Country(1, 'USA')..president = 1,
  Country(2, 'Russia')..president = 2,
  Country(3, 'Germany')..president = 3
];

final persons = [
  Person(1, 'Donald Trump'),
  Person(2, 'Valdimir Putin'),
  Person(3, 'Frank-Walter Steinmeier'),
];
