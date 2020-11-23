import 'package:json_api/client.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/server/_internal/demo_server.dart';
import 'package:json_api/src/server/_internal/in_memory_repo.dart';
import 'package:json_api/src/server/_internal/repository_controller.dart';
import 'package:json_api/src/server/_internal/routing_http_handler.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import 'shared.dart';

void main() {
  JsonApiClient client;
  DemoServer server;

  setUp(() async {
    final handler =
      RoutingHttpHandler(RepositoryController(InMemoryRepo(['users', 'posts', 'comments']), Uuid().v4));
    server = DemoServer(handler, port: 8001);
    await server.start();
    client = JsonApiClient(RecommendedUrlDesign(server.uri));
  });

  tearDown(() async {
    await server.stop();
  });

  test('Client and server can interact over HTTP',
      () => expectAllHttpMethodsToWork(client));
}
