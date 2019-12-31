import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:json_api/src/server/json_api_controller.dart';
import 'package:json_api/src/server/json_api_request.dart';
import 'package:json_api/src/server/response/error_response.dart';
import 'package:json_api/src/server/response/json_api_response.dart';
import 'package:json_api/src/server/routing/route_factory.dart';
import 'package:json_api/src/server/server_document_factory.dart';
import 'package:json_api/url_design.dart';

class JsonApiServer {
  final UrlDesign urlDesign;
  final JsonApiController controller;
  final ServerDocumentFactory documentFactory;
  final String allowOrigin;
  final RouteFactory routeMapper;

  JsonApiServer(this.urlDesign, this.controller,
      {this.allowOrigin = '*', ServerDocumentFactory documentFactory})
      : routeMapper = RouteFactory(),
        documentFactory = documentFactory ?? ServerDocumentFactory(urlDesign);

  Future serve(HttpRequest request) async {
    final response = await _call(controller, request);

    _setStatus(request, response);
    _setHeaders(request, response);
    _writeBody(request, response);

    return request.response.close();
  }

  Future<JsonApiResponse> _call(
      JsonApiController controller, HttpRequest request) async {
    final body = await _getBody(request);
    final jsonApiRequest =
        JsonApiRequest(request.method, request.requestedUri, body);
    try {
      return await urlDesign
          .match(request.requestedUri, routeMapper)
          .call(controller, jsonApiRequest);
    } on ErrorResponse catch (error) {
      return error;
    }
  }

  void _writeBody(HttpRequest request, JsonApiResponse response) {
    final doc = response.buildDocument(documentFactory, request.requestedUri);
    if (doc != null) request.response.write(json.encode(doc));
  }

  void _setStatus(HttpRequest request, JsonApiResponse response) {
    request.response.statusCode = response.status;
  }

  void _setHeaders(HttpRequest request, JsonApiResponse response) {
    final add = request.response.headers.add;
    response.getHeaders(urlDesign).forEach(add);
    if (allowOrigin != null) add('Access-Control-Allow-Origin', allowOrigin);
  }

  Future<Object> _getBody(HttpRequest request) async {
    // https://github.com/dart-lang/sdk/issues/36900
    final body = await request.cast<List<int>>().transform(utf8.decoder).join();
    return (body.isNotEmpty) ? json.decode(body) : null;
  }
}
