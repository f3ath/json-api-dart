import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/json_api_request.dart';
import 'package:json_api/src/server/request_converter.dart';

/// A simple implementation of JSON:API server
class JsonApiServer implements HttpHandler {
  JsonApiServer(this._controller, {RouteFactory routing})
      : _routing = routing ?? StandardRouting();

  final RouteFactory _routing;
  final Controller _controller;

  @override
  Future<HttpResponse> call(HttpRequest httpRequest) async {
    JsonApiRequest jsonApiRequest = InvalidRequest();
    jsonApiRequest.routeFactory = _routing;
    jsonApiRequest.uri = httpRequest.uri;
    try {
      jsonApiRequest = RequestConverter().convert(httpRequest);
      jsonApiRequest.routeFactory = _routing;
      jsonApiRequest.uri = httpRequest.uri;
    } on FormatException catch (e) {
      jsonApiRequest.respond(ErrorResponse.badRequest([
        ErrorObject(
            status: '400',
            title: 'Bad request',
            detail: 'Invalid JSON. ${e.message}')
      ]));
    } on DocumentException catch (e) {
      jsonApiRequest.respond(ErrorResponse.badRequest([
        ErrorObject(status: '400', title: 'Bad request', detail: e.message)
      ]));
    } on MethodNotAllowedException catch (e) {
      jsonApiRequest.respond(ErrorResponse.methodNotAllowed([
        ErrorObject(
            status: '405',
            title: 'Method Not Allowed',
            detail: 'Allowed methods: ${e.allow.join(', ')}')
      ], e.allow));
    } on UnmatchedUriException {
      jsonApiRequest.respond(ErrorResponse.notFound([
        ErrorObject(
            status: '404',
            title: 'Not Found',
            detail: 'The requested URL does exist on the server')
      ]));
    } on IncompleteRelationshipException {
      jsonApiRequest.respond(ErrorResponse.badRequest([
        ErrorObject(
            status: '400',
            title: 'Bad request',
            detail: 'Incomplete relationship object')
      ]));
    }

    await jsonApiRequest.handleWith(_controller);
    return jsonApiRequest.getHttpResponse();
  }
}
