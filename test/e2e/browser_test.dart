import 'package:http_interop_http/http_interop_http.dart';
import 'package:json_api/client.dart';
import 'package:json_api/routing.dart';
import 'package:test/test.dart';

import 'e2e_test_set.dart';

void main() {
  late RoutingClient client;
  group('On Browser', () {
    setUpAll(() async {
      final channel = spawnHybridUri('hybrid_server.dart');
      final serverUrl = await channel.stream.first;

      client = RoutingClient(StandardUriDesign(Uri.parse(serverUrl.toString())),
          Client(OneOffHandler()));
    });

    testLocationIsSet(() => client);
    testAllHttpMethods(() => client);
  }, testOn: 'browser');
}
