import 'package:json_api/client.dart';
import 'package:json_api/routing.dart';
import 'package:test/test.dart';

import '../../example/server/json_api_server.dart';
import '../test_handler.dart';
import 'e2e_test_set.dart';
import 'one_off_handler.dart';

void main() {
  late RoutingClient client;
  late JsonApiServer server;

  group('On VM', () {
    setUpAll(() async {
      server = JsonApiServer(testHandler(), port: 8001);
      await server.start();
      client = RoutingClient(
          StandardUriDesign(
              Uri(scheme: 'http', host: server.host, port: server.port)),
          Client(oneOffHandler));
    });

    tearDownAll(() async {
      await server.stop();
    });

    testLocationIsSet(() => client);
    testAllHttpMethods(() => client);
  }, testOn: 'vm');
}
