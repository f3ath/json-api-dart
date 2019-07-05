import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:json_api/src/document/document_builder.dart';
import 'package:json_api/src/query/query.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/response.dart';
import 'package:json_api/src/server/router.dart';
import 'package:json_api/url_design.dart';

class Server {
  final UrlDesign urlDesign;
  final Controller controller;
  final DocumentBuilder documentBuilder;
  final String allowOrigin;
  final Router router;

  Server(this.urlDesign, this.controller, this.documentBuilder,
      {this.allowOrigin = '*'})
      : router = Router(urlDesign);

  Future serve(HttpRequest request) async {
    final response = await _call(controller, request);

    _setStatus(request, response);
    _setHeaders(request, response);
    _writeBody(request, response);

    return request.response.close();
  }

  Future<Response> _call(Controller controller, HttpRequest request) async {
    final route = router.getRoute(request.requestedUri);
    final query = Query(request.requestedUri.queryParametersAll);
    final method = Method(request.method);
    final body = await _getBody(request);
    try {
      return await route.call(controller, query, method, body);
    } on ErrorResponse catch (error) {
      return error;
    }
  }

  void _writeBody(HttpRequest request, Response response) {
    final doc = response.getDocument(documentBuilder, request.requestedUri);
    if (doc != null) request.response.write(json.encode(doc));
  }

  void _setStatus(HttpRequest request, Response response) {
    request.response.statusCode = response.status;
  }

  void _setHeaders(HttpRequest request, Response response) {
    final add = request.response.headers.add;
    response.getHeaders(urlDesign).forEach(add);
    if (allowOrigin != null) add('Access-Control-Allow-Origin', allowOrigin);
  }

  Future<Object> _getBody(HttpRequest request) async {
    // @see https://github.com/dart-lang/sdk/issues/36900
    final body = await request.cast<List<int>>().transform(utf8.decoder).join();
    return (body.isNotEmpty) ? json.decode(body) : null;
  }
}
