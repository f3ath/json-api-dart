import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/request.dart';
import 'package:json_api/src/server/request_factory.dart';
import 'package:json_api/src/server/request_handler.dart';

/// A simple implementation of JSON:API server
class JsonApiServer implements HttpHandler {
  @override
  Future<HttpResponse> call(HttpRequest httpRequest) async {
    Request jsonApiRequest;
    Response jsonApiResponse;
    try {
      jsonApiRequest = RequestFactory().createFromHttp(httpRequest);
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
    final responseFactory = HttpResponseFactory(documentFactory, _routing);
    return jsonApiResponse.convert(responseFactory);
  }

  JsonApiServer(this._controller, {RouteFactory routing})
      : _routing = routing ?? StandardRouting();

  final RouteFactory _routing;
  final RequestHandler<FutureOr<Response>> _controller;
}
