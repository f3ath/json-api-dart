import 'package:http_interop_http/http_interop_http.dart';
import 'package:json_api/client.dart';
import 'package:json_api/routing.dart';
import 'package:test/test.dart';

import '../../example/server/json_api_server.dart';
import '../test_handler.dart';
import 'e2e_test_set.dart';

void main() {
  late RoutingClient client;
  late JsonApiServer server;

  group('On VM', () {
    setUpAll(() async {
      server = JsonApiServer(TestHandler(), port: 8001);
      await server.start();
      client = RoutingClient(
          StandardUriDesign(
              Uri(scheme: 'http', host: server.host, port: server.port)),
          Client(OneOffHandler()));
    });

    tearDownAll(() async {
      await server.stop();
    });

    testLocationIsSet(() => client);
    testAllHttpMethods(() => client);
  }, testOn: 'vm');
}
