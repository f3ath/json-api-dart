// @dart=2.9
import 'package:json_api/client.dart';
import 'package:json_api/routing.dart';
import 'package:test/test.dart';

import 'e2e_test_set.dart';

void main() {
  JsonApiClient client;

  setUp(() async {
    final channel = spawnHybridUri('hybrid_server.dart');
    final serverUrl = await channel.stream.first;
    // final serverUrl = 'http://localhost:8080';

    client = JsonApiClient(DartHttpHandler(),
        RecommendedUrlDesign(Uri.parse(serverUrl.toString())));
  });
  test('On Browser', () {
    e2eTests(client);
  }, testOn: 'browser');
}
