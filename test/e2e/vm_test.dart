// @dart=2.10
import 'package:json_api/client.dart';
import 'package:json_api/routing.dart';
import 'package:test/test.dart';

import '../src/demo_handler.dart';
import '../src/json_api_server.dart';
import 'e2e_test_set.dart';

void main() {
  JsonApiClient client;
  JsonApiServer server;

  setUp(() async {
    server = JsonApiServer(DemoHandler(), port: 8001);
    await server.start();
    client = JsonApiClient(DartHttpHandler(), RecommendedUrlDesign(server.uri));
  });

  tearDown(() async {
    await server.stop();
  });

  test('On VM', () {
    e2eTests(client);
  }, testOn: 'vm');
}
