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
  final Controller<FutureOr<JsonApiResponse>> _controller;

  @override
  Future<HttpResponse> call(HttpRequest httpRequest) async {
    JsonApiRequest jsonApiRequest;
    JsonApiResponse jsonApiResponse;
    try {
      jsonApiRequest = RequestConverter().convert(httpRequest);
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
    } on UnmatchedUriException {
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
    jsonApiResponse ??= await jsonApiRequest.handleWith(_controller) ??
        ErrorResponse.internalServerError([
          ErrorObject(
              status: '500',
              title: 'Internal Server Error',
              detail: 'Controller responded with null')
        ]);

    final links = StandardLinks(httpRequest.uri, _routing);
    final documentFactory = DocumentFactory(links: links);
    final responseFactory = HttpResponseConverter(documentFactory, _routing);
    return jsonApiResponse.convert(responseFactory);
  }
}
