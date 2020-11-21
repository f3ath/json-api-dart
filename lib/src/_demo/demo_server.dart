import 'dart:io';

import 'package:json_api/http.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/_demo/cors_handler.dart';
import 'package:json_api/src/_demo/dart_io_http_handler.dart';
import 'package:json_api/src/_demo/repo.dart';
import 'package:json_api/src/_demo/repository_controller.dart';
import 'package:pedantic/pedantic.dart';
import 'package:uuid/uuid.dart';

class DemoServer {
  DemoServer(Repo repo,
      {this.host = 'localhost',
      this.port = 8080,
      HttpLogger logger = const CallbackHttpLogger(),
      String Function() idGenerator,
      bool exposeInternalErrors = false})
      : _handler = LoggingHttpHandler(
            CorsHandler(JsonApiHandler(
                RepositoryController(repo, idGenerator ?? Uuid().v4),
                exposeInternalErrors: exposeInternalErrors)),
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
