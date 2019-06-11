import 'dart:convert';
import 'dart:io';

import 'package:json_api/src/document/json_api_error.dart';
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
    } else if (!controller.supportsType(target.type)) {
      return _send(
          http,
          ErrorResponse.notFound(
              [JsonApiError(detail: 'Unknown resource type')]));
    }

    final request = target.getRequest(http.method, requestFactory);

    final body = await http.transform(utf8.decoder).join();

    final response = await request.call(
            controller,
            http.requestedUri.queryParametersAll,
            body.isNotEmpty ? json.decode(body) : null) ??
        ErrorResponse.notImplemented([]);

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
