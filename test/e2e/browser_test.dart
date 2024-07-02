import 'package:json_api/client.dart';
import 'package:json_api/routing.dart';
import 'package:test/test.dart';

import 'e2e_test_set.dart';
import 'one_off_handler.dart';

void main() {
  late RoutingClient client;
  group('On Browser', () {
    setUpAll(() async {
      final channel = spawnHybridUri('hybrid_server.dart');
      final serverUrl = await channel.stream.first;
      client = RoutingClient(StandardUriDesign(Uri.parse(serverUrl.toString())),
          Client(oneOffHandler));
    });

    testLocationIsSet(() => client);
    testAllHttpMethods(() => client);
  }, testOn: 'browser');
}
