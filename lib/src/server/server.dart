import 'dart:convert';
import 'dart:io';

import 'package:json_api/src/server/_server.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/request/match_target.dart';
import 'package:json_api/src/server/response.dart';
import 'package:json_api/src/server/server_document_builder.dart';

class Server {
  final UrlDesign routing;
  final Controller controller;
  final ServerDocumentBuilder documentBuilder;
  final String allowOrigin;

  Server(this.routing, this.controller, this.documentBuilder,
      {this.allowOrigin = '*'});

  Future process(HttpRequest http) async {
    final target = matchTarget(routing, http.requestedUri);

    Response response;
    try {
      response = await target.getRequest(http.method).call(controller,
          http.requestedUri.queryParametersAll, await _getPayload(http));
    } on ErrorResponse catch (error) {
      response = error;
    }

    return _send(http, response);
  }

  Future<Object> _getPayload(HttpRequest http) async {
    // @see https://github.com/dart-lang/sdk/issues/36900
    final body = await http.cast<List<int>>().transform(utf8.decoder).join();
    if (body.isNotEmpty) return json.decode(body);
    return null;
  }

  Future _send(HttpRequest http, Response response) {
    http.response.statusCode = response.status;
    response.getHeaders(routing).forEach(http.response.headers.add);
    if (allowOrigin != null) {
      http.response.headers.add('Access-Control-Allow-Origin', allowOrigin);
    }
    final doc = response.getDocument(documentBuilder, http.requestedUri);
    if (doc != null) {
      http.response.write(json.encode(doc));
    }
    return http.response.close();
  }
}
