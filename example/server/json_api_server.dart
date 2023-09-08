import 'dart:io';

import 'package:http_interop/http_interop.dart';
import 'package:http_interop_io/http_interop_io.dart';

class JsonApiServer {
  JsonApiServer(
    this._handler, {
    this.host = 'localhost',
    this.port = 8080,
  });

  /// Server host name
  final String host;

  /// Server port
  final int port;

  final Handler _handler;
  HttpServer? _server;

  /// Server uri
  Uri get uri => Uri(scheme: 'http', host: host, port: port);

  /// starts the server
  Future<void> start() async {
    if (_server != null) return;
    try {
      _server = await _createServer();
    } on Exception {
      await stop();
      rethrow;
    }
  }

  /// Stops the server
  Future<void> stop({bool force = false}) async {
    await _server?.close(force: force);
    _server = null;
  }

  Future<HttpServer> _createServer() async {
    final server = await HttpServer.bind(host, port);
    server.listen(listener(_handler));
    return server;
  }
}
