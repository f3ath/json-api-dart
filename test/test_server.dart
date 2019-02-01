import 'dart:io';

import 'package:json_api/document.dart';
import 'package:json_api/server.dart';

class TestServer {
  HttpServer httpServer;

  Future start(InternetAddress addr, int port) async {
    final collections = {
      'cities': [
        City(1, 'Munich'),
        City(2, 'Palo Alto'),
        City(3, 'Ingolstadt'),
      ],
      'brands': [
        Brand(1, 'Tesla', headquarters: 1),
        Brand(2, 'BMW', headquarters: 2),
        Brand(3, 'Audi', headquarters: 3),
        Brand(4, 'Ford'),
        Brand(5, 'Toyota')
      ],
    };

    final jsonApiServer = JsonApiServer<HttpRequest>(
        TestController(collections),
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

JsonApiRequest<HttpRequest> resolveAction(HttpRequest rq) {
  final seg = rq.uri.pathSegments;
  switch (seg.length) {
    case 1:
      return CollectionRequest(seg[0],
          httpRequest: rq, queryParameters: rq.uri.queryParameters);
    case 2:
      return ResourceRequest(seg[0], seg[1], httpRequest: rq);
    case 3:
      return RelatedRequest(seg[0], seg[1], seg[2], httpRequest: rq);
    case 4:
      if (seg[2] == 'relationships') {
        return RelationshipRequest(seg[0], seg[1], seg[3], httpRequest: rq);
      }
  }
  return null;
}

class TestController implements ResourceController<HttpRequest> {
  final mappers = {
    Brand: (Brand _) => Resource('brands', _.id.toString(), attributes: {
          'name': _.name
        }, relationships: {
          'headquarters': ToOne(Identifier('cities', _.headquarters.toString()))
        })
  };

  final Map<String, List<HasId>> collections;

  TestController(this.collections);

  Resource _map(Object obj) => mappers[obj.runtimeType](obj);

  Future<Collection<Resource>> fetchCollection(
      CollectionRequest<HttpRequest> rq) async {
    final page = NumberedPage.fromQueryParameters(rq.queryParameters,
        total: collections[rq.type].length);
    return Collection(
        collections[rq.type].skip(page.number - 1).take(1).map(_map),
        page: page);
  }

  @override
  Future<Resource> fetchResource(ResourceRequest<HttpRequest> rq) async {
    return _map(
        collections[rq.type].firstWhere((_) => _.id.toString() == rq.id));
  }

  @override
  bool supports(String type) => collections.containsKey(type);

  @override
  Future<Resource> fetchRelated(RelatedRequest<HttpRequest> rq) async {
    final res =
        collections[rq.type].firstWhere((_) => _.id.toString() == rq.id);
    if (res is Brand) {
      if (rq.name == 'headquarters') {
        return _map(collections['cities']
            .firstWhere((_) => _.id.toString() == res.headquarters));
      }
    }
    return null;
  }

  Future<Relationship> fetchRelationship(RelationshipRequest rq) async {
    final res =
        collections[rq.type].firstWhere((_) => _.id.toString() == rq.id);
    if (res is Brand) {
      if (rq.name == 'headquarters') {
        return ToOne(Identifier('cities', res.headquarters.toString()));
      }
    }
    return null;
  }
}

abstract class HasId {
  int get id;
}

class Brand implements HasId {
  final String name;
  final int id;
  final int headquarters;

  Brand(this.id, this.name, {this.headquarters});
}

class City implements HasId {
  final String name;
  final int id;

  City(this.id, this.name);
}
