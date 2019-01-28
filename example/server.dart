import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:json_api/document.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/recommended_routing.dart';

Future main() async {
  var server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    8080,
  );
  print('Listening on localhost:${server.port}');

  await for (HttpRequest request in server) {
    final rq = await routing.createRequest(request.uri, request.method);
    final doc = await rq.handleBy(controller);
    request.response
      ..headers.contentType = ContentType('application', 'vnd.api+json')
      ..write(json.encode(doc))
      ..close();
  }
}

final routing = RecommendedRouting(Uri.parse('http://localhost:8080'));

final controller = DocumentController();

class DocumentController implements Controller<FutureOr<Document>> {
  final provider = ResourceProvider();

  @override
  FutureOr<Document> fetchCollection(CollectionRequest rq) async {
    final c = await provider.fetchCollection(rq.type);
    Iterable<Resource> linked = _addLinks(c.elements);
    final pagination = PaginationLinks(next: c.page?.next)
    return CollectionDocument(linked.toList(),
        self: routing.collectionLink(rq.type));
  }

  Iterable<Resource> _addLinks(Iterable<Resource> rs) =>
      rs.map((r) => r.replace(
          self: routing.resourceLink(r.type, r.id),
          relationships: r.relationships.map((name, _) => MapEntry(
              name,
              _.replace(
                  related: routing.relatedLink(r.type, r.id, name),
                  self: routing.relationshipLink(r.type, r.id, name))))));
}

class Collection<T> {
  Iterable<T> elements;
  Page page;

  Collection(this.elements, {this.page});
}

class ResourceProvider<R> {
  FutureOr<Collection<Resource>> fetchCollection(String type) {
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
