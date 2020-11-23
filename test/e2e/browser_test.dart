import 'package:json_api/client.dart';
import 'package:json_api/routing.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:test/test.dart';

import '../shared.dart';


void main() {
  StreamChannel channel;
  JsonApiClient client;

  setUp(() async {
    channel = spawnHybridUri('hybrid_server.dart');
    final serverUrl = await channel.stream.first;
    // final serverUrl = 'http://localhost:8080';

    client =
        JsonApiClient(RecommendedUrlDesign(Uri.parse(serverUrl.toString())));
  });

  test('All possible HTTP methods are usable in browsers',
      () => expectAllHttpMethodsToWork(client));
}
