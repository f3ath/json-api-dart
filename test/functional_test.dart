import 'dart:io';

import 'package:json_api/client.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:test/test.dart';

void main() {
  HttpServer httpServer;
  JsonApiServer<HttpRequest> jsonApiServer;
  setUp(() async {
    jsonApiServer = JsonApiServer<HttpRequest>(controller, resolveAction,
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
  });

  tearDown(() {
    httpServer.close();
  });

//  test('get first page of collection', () async {
//    final c = JsonApiClient();
//    final doc =
//        await c.fetchCollection(Uri.parse('http://localhost:8080/brands'));
//    expect(doc.collection.first.attributes['name'], 'Tesla');
//
//    expect(doc.self.href, 'http://localhost:8080/brands');
//    expect(doc.first.href, 'http://localhost:8080/brands');
//    expect(doc.last.href, 'http://localhost:8080/brands?page%5Bnumber%5D=5');
//    expect(doc.prev.href, 'http://localhost:8080/brands');
//    expect(doc.next.href, 'http://localhost:8080/brands?page%5Bnumber%5D=2');
//  });

  test('get second page of collection', () async {
    final c = JsonApiClient();
    final doc = await c.fetchCollection(
        Uri.parse('http://localhost:8080/brands')
            .replace(queryParameters: {'page[number]': '2'}));
    expect(doc.collection.first.attributes['name'], 'Tesla');

    expect(doc.self.href, 'http://localhost:8080/brands?page%5Bnumber%5D=2');
    expect(doc.first.href, 'http://localhost:8080/brands');
    expect(doc.last.href, 'http://localhost:8080/brands?page%5Bnumber%5D=5');
    expect(doc.prev.href, 'http://localhost:8080/brands');
    expect(doc.next.href, 'http://localhost:8080/brands?page%5Bnumber%5D=3');
  });

  test('get single resource', () async {
    final c = JsonApiClient();
    final doc =
        await c.fetchResource(Uri.parse('http://localhost:8080/brands/1'));
    expect(doc.resource.attributes['name'], 'Tesla');
  });

  test('get collection - 404', () async {
    final c = JsonApiClient();
    try {
      await c.fetchCollection(Uri.parse('http://localhost:8080/unicorns'));
      fail('exception expected');
    } on NotFoundException {}
  });
}

JsonApiRequest<HttpRequest> resolveAction(HttpRequest rq) {
  final seg = rq.uri.pathSegments;
  if (seg.length == 1) {
    return CollectionRequest(seg[0], httpRequest: rq);
  } else if (seg.length == 2) {
    return ResourceRequest(seg[0], seg[1], httpRequest: rq);
  }
  return null;
}

final controller = TestController();

class TestController implements ResourceController<HttpRequest> {
  final mapper = {
    Brand: (Brand _) =>
        Resource('brands', _.id.toString(), attributes: {'name': _.name})
  };

  Future<Collection<Resource>> fetchCollection(
      CollectionRequest<HttpRequest> rq) async {
    switch (rq.type) {
      case 'brands':
        return Collection(brands.map(mapper[Brand]),
            page: NumberedPage(2, total: 5));
    }
    return null;
  }

  @override
  Future<Resource> fetchResource(ResourceRequest<HttpRequest> rq) async {
    return mapper[Brand](brands.firstWhere((_) => _.id.toString() == rq.id));
  }

  @override
  bool supports(String type) => ['brands'].contains(type);
}

class Brand {
  final String name;
  final int id;

  Brand(this.id, this.name);
}

final brands = [Brand(1, 'Tesla')];
