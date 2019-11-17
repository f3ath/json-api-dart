import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:json_api/src/document_factory.dart';
import 'package:json_api/src/query/query.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/response.dart';
import 'package:json_api/src/server/router.dart';
import 'package:json_api/url_design.dart';

class Server {
  final UrlDesign urlDesign;
  final Controller controller;
  final DocumentFactory documentBuilder;
  final String allowOrigin;
  final RouteMapper routeMapper;

  Server(this.urlDesign, this.controller, this.documentBuilder,
      {this.allowOrigin = '*'})
      : routeMapper = RouteMapper();

  Future serve(HttpRequest request) async {
    final response = await _call(controller, request);

    _setStatus(request, response);
    _setHeaders(request, response);
    _writeBody(request, response);

    return request.response.close();
  }

  Future<Response> _call(Controller controller, HttpRequest request) async {
    final query = Query(request.requestedUri);
    final method = Method(request.method);
    final body = await _getBody(request);
    try {
      return await urlDesign
          .matchAndMap(request.requestedUri, routeMapper)
          .call(controller, query, method, body);
    } on ErrorResponse catch (error) {
      return error;
    }
  }

  void _writeBody(HttpRequest request, Response response) {
    final doc = response.buildDocument(documentBuilder, request.requestedUri);
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
