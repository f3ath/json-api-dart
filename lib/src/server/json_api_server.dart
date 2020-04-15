import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/request_context.dart';
import 'package:json_api/src/server/response.dart';
import 'package:json_api/src/server/route.dart';
import 'package:json_api/src/server/route_matcher.dart';

/// A simple implementation of JSON:API server
class JsonApiServer implements HttpHandler {
  JsonApiServer(this._controller,
      {Routing routing, DocumentFactory documentFactory})
      : _routing = routing ?? StandardRouting(),
        _doc = documentFactory ?? DocumentFactory();

  final Routing _routing;
  final Controller _controller;
  final DocumentFactory _doc;

  @override
  Future<HttpResponse> call(HttpRequest httpRequest) async {
    final context = RequestContext(_doc, _routing);

    final matcher = RouteMatcher();
    _routing.match(httpRequest.uri, matcher);
    final route = matcher.route;

    if (route == null) {
      return context.convert(ErrorResponse(404, [
        ErrorObject(
          status: '404',
          title: 'Not Found',
          detail: 'The requested URL does exist on the server',
        )
      ]));
    }

    final route2 = CorsEnabled(route);

    if (!route2.allowedMethods.contains(httpRequest.method)) {
      return context.convert(ExtraHeaders(
          ErrorResponse(405, []), {'Allow': route2.allowedMethods.join(', ')}));
    }

    try {
      return context.convert(await route2.dispatch(httpRequest, _controller));
    } on FormatException catch (e) {
      return context.convert(ErrorResponse(400, [
        ErrorObject(
          status: '400',
          title: 'Bad Request',
          detail: 'Invalid JSON. ${e.message}',
        )
      ]));
    } on DocumentException catch (e) {
      return context.convert(ErrorResponse(400, [
        ErrorObject(
          status: '400',
          title: 'Bad Request',
          detail: e.message,
        )
      ]));
    } on IncompleteRelationshipException {
      return context.convert(ErrorResponse(400, [
        ErrorObject(
          status: '400',
          title: 'Bad Request',
          detail: 'Incomplete relationship object',
        )
      ]));
    }
  }
}
