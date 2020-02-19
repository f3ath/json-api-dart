import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/json_api_request.dart';
import 'package:json_api/src/server/request_factory.dart';

class JsonApiServer implements HttpHandler {
  @override
  Future<HttpResponse> call(HttpRequest httpRequest) async {
    final factory = JsonApiRequestFactory();
    JsonApiRequest jsonApiRequest;
    JsonApiResponse jsonApiResponse;

    try {
      jsonApiRequest = factory.getJsonApiRequest(httpRequest);
    } on FormatException catch (e) {
      jsonApiResponse = ErrorResponse.badRequest([
        ErrorObject(
            status: '400',
            title: 'Bad request',
            detail: 'Invalid JSON. ${e.message}')
      ]);
    } on DocumentException catch (e) {
      jsonApiResponse = ErrorResponse.badRequest([
        ErrorObject(status: '400', title: 'Bad request', detail: e.message)
      ]);
    } on MethodNotAllowedException catch (e) {
      jsonApiResponse = ErrorResponse.methodNotAllowed([
        ErrorObject(
            status: '405',
            title: 'Method Not Allowed',
            detail: 'Allowed methods: ${e.allow.join(', ')}')
      ], e.allow);
    } on InvalidUriException {
      jsonApiResponse = ErrorResponse.notFound([
        ErrorObject(
            status: '404',
            title: 'Not Found',
            detail: 'The requested URL does exist on the server')
      ]);
    } on IncompleteRelationshipException {
      jsonApiResponse = ErrorResponse.badRequest([
        ErrorObject(
            status: '400',
            title: 'Bad request',
            detail: 'Incomplete relationship object')
      ]);
    }

    // Implementation-specific logic (e.g. auth) goes here

    jsonApiResponse ??= await jsonApiRequest.call(_controller);

    // Any response post-processing goes here
    return jsonApiResponse
        .httpResponse(HttpResponseFactory(_routing, httpRequest.uri));
  }

  JsonApiServer(this._routing, this._controller);

  final Routing _routing;
  final JsonApiController _controller;
}
