// @dart=2.9
import 'package:json_api/client.dart';
import 'package:json_api/routing.dart';
import 'package:test/test.dart';

import '../../legacy/dart_http_handler.dart';
import 'e2e_test_set.dart';

void main() {
  RoutingClient client;

  setUp(() async {
    final channel = spawnHybridUri('hybrid_server.dart');
    final serverUrl = await channel.stream.first;
    // final serverUrl = 'http://localhost:8080';

    client = RoutingClient(StandardUriDesign(Uri.parse(serverUrl.toString())),
        BasicClient(DartHttpHandler()));
  });
  test('On Browser', () {
    e2eTests(client);
  }, testOn: 'browser');
}
