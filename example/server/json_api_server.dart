import 'dart:convert';
import 'dart:io';

import 'package:json_api/http.dart';

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

  final HttpHandler _handler;
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
    server.listen((request) async {
      final headers = <String, String>{};
      request.headers.forEach((k, v) => headers[k] = v.join(','));
      final response = await _handler.handle(HttpRequest(
          request.method, request.requestedUri,
          body: await request.cast<List<int>>().transform(utf8.decoder).join())
        ..headers.addAll(headers));
      response.headers.forEach(request.response.headers.add);
      request.response.statusCode = response.statusCode;
      request.response.write(response.body);
      await request.response.close();
    });
    return server;
  }
}
