import 'package:json_api/client.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/_testing/demo_handler.dart';
import 'package:json_api/src/_testing/json_api_server.dart';
import 'package:test/test.dart';

import 'e2e_test_set.dart';

void main() {
  late RoutingClient client;
  late JsonApiServer server;

  setUp(() async {
    server = JsonApiServer(DemoHandler(), port: 8001);
    await server.start();
    client = RoutingClient(StandardUriDesign(
        Uri(scheme: 'http', host: server.host, port: server.port)));
  });

  tearDown(() async {
    await server.stop();
  });

  test('On VM', () async {
    await e2eTests(client);
  }, testOn: 'vm');
}
