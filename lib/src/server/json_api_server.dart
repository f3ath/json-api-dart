import 'dart:async';

import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/json_api_request.dart';
import 'package:json_api/src/server/request_factory.dart';

class JsonApiServer implements HttpHandler {
  @override
  Future<HttpResponse> call(HttpRequest httpRequest) async {
    final jsonApiRequest =
        JsonApiRequestFactory().getJsonApiRequest(httpRequest);
    // Implementation-specific logic (e.g. auth) goes here
    final jsonApiResponse = await jsonApiRequest.call(_controller);

    final httpResponse = HttpResponseBuilder(_routing, httpRequest.uri);
    jsonApiResponse.build(httpResponse);

    // Any response post-processing goes here
    return httpResponse.buildHttpResponse();
  }

  JsonApiServer(this._routing, this._controller);

  final Routing _routing;
  final JsonApiController _controller;
}
