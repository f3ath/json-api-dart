import 'dart:async';
import 'dart:convert';

import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/json_api_request.dart';
import 'package:json_api/src/server/request_factory.dart';

class JsonApiServer implements HttpHandler {
  @override
  Future<HttpResponse> call(HttpRequest request) async {
    final rq = JsonApiRequestFactory().getJsonApiRequest(request);
    // Implementation-specific logic (e.g. auth) goes here
    final response = await rq.call(_controller);

    // Build response Document
    response.buildDocument(_factory, request.uri);
    final document = _factory.build();

    // Any response post-processing goes here
    return HttpResponse(response.statusCode,
        body: document == null ? null : jsonEncode(document),
        headers: response.buildHeaders(_routing));
  }

  JsonApiServer(this._routing, this._controller,
      {ResponseDocumentFactory documentFactory})
      : _factory = documentFactory ?? ResponseDocumentFactory(_routing);

  final Routing _routing;
  final JsonApiController _controller;
  final ResponseDocumentFactory _factory;
}
