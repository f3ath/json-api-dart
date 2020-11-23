import 'dart:io';

import 'package:json_api/http.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/_internal/cors_handler.dart';
import 'package:json_api/src/server/_internal/dart_io_http_handler.dart';
import 'package:json_api/src/server/_internal/repo.dart';
import 'package:json_api/src/server/_internal/repository_controller.dart';
import 'package:json_api/src/server/_internal/repository_error_converter.dart';
import 'package:json_api/src/server/_internal/routing_http_handler.dart';
import 'package:json_api/src/server/chain_error_converter.dart';
import 'package:json_api/src/server/routing_error_handler.dart';
import 'package:pedantic/pedantic.dart';
import 'package:uuid/uuid.dart';

class DemoServer {
  DemoServer(
    Repo repo, {
    this.host = 'localhost',
    this.port = 8080,
    HttpLogger logger = const CallbackHttpLogger(),
    String Function() idGenerator,
  }) : _handler = LoggingHttpHandler(
            CorsHandler(TryCatchHttpHandler(
              RoutingHttpHandler(
                  RepositoryController(repo, idGenerator ?? Uuid().v4)),
              ChainErrorConverter(
                  [RepositoryErrorConverter(), RoutingErrorHandler()]),
            )),
            logger);

  final String host;
  final int port;
  final HttpHandler _handler;

  HttpServer _server;

  Uri get uri => Uri(scheme: 'http', host: host, port: port);

  Future<void> start() async {
    if (_server != null) return;
    try {
      _server = await HttpServer.bind(host, port);
      unawaited(_server.forEach(DartIOHttpHandler(_handler)));
    } on Exception {
      await stop();
      rethrow;
    }
  }

  Future<void> stop({bool force = false}) async {
    if (_server == null) return;
    await _server.close(force: force);
    _server = null;
  }
}
