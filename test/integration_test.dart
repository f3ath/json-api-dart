import 'package:json_api/client.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/server/_internal/demo_server.dart';
import 'package:json_api/src/server/_internal/in_memory_repo.dart';
import 'package:test/test.dart';

import 'shared.dart';

void main() {
  JsonApiClient client;
  DemoServer server;

  setUp(() async {
    final repo = InMemoryRepo(['posts']);
    server = DemoServer(repo, port: 8001);
    await server.start();
    client = JsonApiClient(RecommendedUrlDesign(server.uri));
  });

  tearDown(() async {
    await server.stop();
  });

  test('Client and server can interact over HTTP',
      () => expectAllHttpMethodsToWork(client));
}
