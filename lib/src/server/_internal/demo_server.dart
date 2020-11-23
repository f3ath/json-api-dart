import 'dart:io';

import 'package:json_api/http.dart';
import 'package:json_api/src/server/_internal/dart_io_http_handler.dart';
import 'package:pedantic/pedantic.dart';

class DemoServer {
  DemoServer(
    this.handler, {
    this.host = 'localhost',
    this.port = 8080,
  });

  final String host;
  final int port;
  final HttpHandler handler;

  HttpServer _server;

  Uri get uri => Uri(scheme: 'http', host: host, port: port);

  Future<void> start() async {
    if (_server != null) return;
    try {
      _server = await HttpServer.bind(host, port);
      unawaited(_server.forEach(DartIOHttpHandler(handler)));
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
