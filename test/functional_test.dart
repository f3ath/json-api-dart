import 'dart:io';

import 'package:json_api/client.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:test/test.dart';

void main() {
  HttpServer httpServer;
  JsonApiServer jsonApiServer;
  setUp(() async {
    jsonApiServer = JsonApiServer(controller);
    httpServer = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      8080,
    );
    httpServer.forEach((rq) async {
      final rs = await jsonApiServer.handle(ServerRequest(rq.uri));

      rq.response
        ..statusCode = rs.status
        ..write(rs.body)
        ..close();
    });
  });

  tearDown(() {
    httpServer.close();
  });

  test('get collection', () async {
    final c = JsonApiClient();
    final doc = await c.fetchCollection('http://localhost:8080/brands');
    expect(doc.collection.first.attributes['name'], 'Tesla');
  });

  test('get collection - 404', () async {
    final c = JsonApiClient();
    try {
      await c.fetchCollection('http://localhost:8080/unicorns');
      fail('exception expected');
    } on NotFoundException {}
  });
}

final controller = TestController();

class TestController implements ResourceController {
  @override
  Future<Collection<Resource>> fetchCollection(String type) async {
    switch (type) {
      case 'brands':
        return Collection([
          Resource(type, '1', attributes: {'name': 'Tesla'})
        ]);
    }
    return null;
  }
}
