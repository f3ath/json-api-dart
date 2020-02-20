import 'dart:io';

import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';

/// This example shows how to run a simple JSON:API server using the built-in
/// HTTP server (dart:io).
/// Run it: `dart example/server.dart`
void main() async {
  /// Listening on this port
  final port = 8080;

  /// Listening on the localhost
  final address = 'localhost';

  /// Base URI to let the URI design detect the request target properly
  final base = Uri(host: address, port: port, scheme: 'http');

  /// Use the standard URI design
  final routing = StandardRouting(base);

  /// Resource repository supports two kind of entities: writers and books
  final repo = InMemoryRepository({'writers': {}, 'books': {}});

  /// Controller provides JSON:API interface to the repository
  final controller = RepositoryController(repo);

  /// The JSON:API server uses the given URI design to route requests to the controller
  final jsonApiServer = JsonApiServer(routing, controller);

  /// We will be logging the requests and responses to the console
  final loggingJsonApiServer = LoggingHttpHandler(jsonApiServer,
      onRequest: (r) => print('${r.method} ${r.uri}'),
      onResponse: (r) => print('${r.statusCode}'));

  /// The handler for the built-in HTTP server
  final serverHandler = DartServer(loggingJsonApiServer);

  /// Start the server
  final server = await HttpServer.bind(address, port);
  print('Listening on $base');

  /// Each HTTP request will be processed by the handler
  await server.forEach(serverHandler);
}
