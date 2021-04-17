import 'package:json_api/client.dart';
import 'package:json_api/routing.dart';
import 'package:test/test.dart';

import 'e2e_test_set.dart';

void main() {
  late RoutingClient client;

  setUp(() async {
    final channel = spawnHybridUri('hybrid_server.dart');
    final serverUrl = await channel.stream.first;

    client = RoutingClient(StandardUriDesign(Uri.parse(serverUrl.toString())));
  });

  test('On Browser', () async {
    await e2eTests(client);
  }, testOn: 'browser');
}
