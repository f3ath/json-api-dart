import 'dart:convert';
import 'dart:io';

import 'package:json_api/server.dart';

/// A simple JSON:API server ot top of Dart's [HttpServer]
class SimpleServer {
  HttpServer _httpServer;
  final ResourceController _controller;

  SimpleServer(this._controller);

  Future start(InternetAddress address, int port) async {
    final jsonApiServer = JsonApiServer(_controller,
        StandardRouting(Uri.parse('http://${address.host}:$port')));

    _httpServer = await HttpServer.bind(address, port);

    _httpServer.forEach((rq) async {
      final rs = await jsonApiServer.handle(
          rq.method, rq.uri, await rq.transform(utf8.decoder).join());
      rq.response.statusCode = rs.status;
      if (rs.body != null) {
        rq.response.write(rs.body);
      }
      rq.response.close();
    });
  }

  Future stop() => _httpServer.close();
}
