import 'dart:convert';
import 'dart:io';

import 'package:json_api/src/server/_server.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/response.dart';
import 'package:json_api/src/server/routing.dart';
import 'package:json_api/src/server/server_document_builder.dart';

class Server {
  final Routing routing;
  final Controller controller;
  final ServerDocumentBuilder builder;
  final String allowOrigin;
  final requestFactory = const DefaultRequestFactory();

  Server(this.routing, this.controller, {this.allowOrigin = '*'})
      : builder = ServerDocumentBuilder(routing);

  Future process(HttpRequest http) async {
    final target = routing.getTarget(http.requestedUri);
    if (target == null) {
      return _send(http, ErrorResponse.badRequest([]));
    }

    final request = target.getDispatcher(http.method, requestFactory);

    final body = await http.transform(utf8.decoder).join();

    Response response;
    try {
      response = await request.dispatchCall(
              controller,
              http.requestedUri.queryParametersAll,
              body.isNotEmpty ? json.decode(body) : null) ??
          ErrorResponse.notImplemented([]);
    } on ErrorResponse catch (e) {
      response = e;
    }

    return _send(http, response);
  }

  Future _send(HttpRequest http, Response response) {
    http.response.statusCode = response.status;
    response.getHeaders(routing).forEach(http.response.headers.add);
    if (allowOrigin != null) {
      http.response.headers.add('Access-Control-Allow-Origin', allowOrigin);
    }
    final doc = response.getDocument(builder, http.requestedUri);
    if (doc != null) {
      http.response.write(json.encode(doc));
    }
    return http.response.close();
  }
}
