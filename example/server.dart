import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:json_api/document.dart';
import 'package:json_api/src/routing.dart';

Future main() async {
  var server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    8080,
  );
  print('Listening on localhost:${server.port}');

  await for (HttpRequest request in server) {
    final route = await router.parse(request);
    final doc = await route.handle(controller, request);
    request.response
      ..headers.contentType = ContentType('application', 'vnd.api+json')
      ..write(json.encode(doc))
      ..close();
  }
}

final router = ExampleRouter();
final controller = ExampleController();

class ExampleController implements Controller<HttpRequest, Document> {
  final links = StandardLinks(Uri.parse('http://localhost:8080'));

  @override
  FutureOr<Document> fetchCollection(
      CollectionRoute route, HttpRequest request) {
    final resources = countries
        .map((_) => Resource('countries', _.id.toString(),
            attributes: {'name': _.name}))
        .toList();
    final doc = CollectionDocument(resources, route: route);
    doc.setLinks(links);
    return doc;
  }

  @override
  FutureOr<Document> fetchRelated(RelatedRoute r, HttpRequest request) {
    // TODO: implement fetchRelated
    return null;
  }

  @override
  FutureOr<Document> fetchRelationship(
      RelationshipRoute r, HttpRequest request) {
    // TODO: implement fetchRelationship
    return null;
  }

  @override
  FutureOr<Document> fetchResource(ResourceRoute r, HttpRequest request) {
    // TODO: implement fetchResource
    return null;
  }
}

abstract class ResourceController<Request> {
  FutureOr<Document> fetchCollection(CollectionRoute route, Request request);
}

class ExampleRouter implements Router<HttpRequest> {
  final r = StandardRouter();

  @override
  FutureOr<Route> parse(HttpRequest request) =>
      r.parse(StandardRouterRequest(request.method, request.uri));
}

class Country {
  final int id;
  final String name;

  Country(this.id, this.name);
}

final countries = [
  Country(1, 'USA'),
  Country(1, 'Russia'),
  Country(1, 'Germany')
];
