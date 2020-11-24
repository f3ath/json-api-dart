import 'package:json_api/client.dart';
import 'package:json_api/routing.dart';
import 'package:json_api_server/json_api_server.dart';
import 'package:test/test.dart';

import '../src/demo_server.dart';
import 'shared.dart';

void main() {
  JsonApiClient client;
  JsonApiServer server;

  setUp(() async {
    server = demoServer(port: 8001);
    await server.start();
    client = JsonApiClient(RecommendedUrlDesign(server.uri));
  });

  tearDown(() async {
    await server.stop();
  });

  group('Integration', () {
    test('Client and server can interact over HTTP',
        () => expectAllHttpMethodsToWork(client));
  }, testOn: 'vm');
}
