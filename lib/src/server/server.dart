import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:json_api/query.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/http_method.dart';
import 'package:json_api/src/server/response/error_response.dart';
import 'package:json_api/src/server/response/response.dart';
import 'package:json_api/src/server/routing/route_factory.dart';
import 'package:json_api/src/server/server_document_factory.dart';
import 'package:json_api/url_design.dart';

class Server {
  final UrlDesign urlDesign;
  final Controller controller;
  final ServerDocumentFactory documentFactory;
  final String allowOrigin;
  final RouteFactory routeMapper;

  Server(this.urlDesign, this.controller, this.documentFactory,
      {this.allowOrigin = '*'})
      : routeMapper = RouteFactory();

  Future serve(HttpRequest request) async {
    final response = await _call(controller, request);

    _setStatus(request, response);
    _setHeaders(request, response);
    _writeBody(request, response);

    return request.response.close();
  }

  Future<Response> _call(Controller controller, HttpRequest request) async {
    final method = HttpMethod(request.method);
    final body = await _getBody(request);
    try {
      return await urlDesign
          .match(request.requestedUri, routeMapper)
          .call(controller, request.requestedUri, method, body);
    } on ErrorResponse catch (error) {
      return error;
    }
  }

  void _writeBody(HttpRequest request, Response response) {
    final doc = response.buildDocument(documentFactory, request.requestedUri);
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
