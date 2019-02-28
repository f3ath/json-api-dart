import 'dart:async';
import 'dart:io';

import 'package:json_api/src/server/resource_controller.dart';
import 'package:json_api/src/server/routing.dart';
import 'package:json_api/src/server/server.dart';

/// A simple JSON:API cars_server ot top of Dart's [HttpServer]
class SimpleServer {
  HttpServer _httpServer;
  final ResourceController _controller;
  final MetaDecorator meta;

  SimpleServer(this._controller, {this.meta});

  Future start(InternetAddress address, int port) async {
    final jsonApiServer = JsonApiServer(
        _controller, StandardRouting(Uri.parse('http://${address.host}:$port')),
        meta: meta);

    _httpServer = await HttpServer.bind(address, port);

    _httpServer.forEach((request) async {
      final serverResponse = await jsonApiServer.handle(request);

      request.response.statusCode = serverResponse.status;
      serverResponse.headers.forEach(request.response.headers.set);
      request.response.headers.set('Access-Control-Allow-Origin', '*');
      if (serverResponse.body != null) {
        request.response.write(serverResponse.body);
      }
      await request.response.close();
    });
  }

  Future stop() => _httpServer.close(force: true);
}
