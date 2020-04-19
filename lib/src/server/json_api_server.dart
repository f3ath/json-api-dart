import 'dart:async';

import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/response_factory.dart';
import 'package:json_api/src/server/route.dart';
import 'package:json_api/src/server/route_matcher.dart';

/// A simple implementation of JSON:API server
class JsonApiServer implements HttpHandler {
  JsonApiServer(this._controller,
      {Routing routing, ResponseFactory responseFactory})
      : _routing = routing ?? StandardRouting(),
        _rf = responseFactory ??
            HttpResponseFactory(routing ?? StandardRouting());

  final Routing _routing;
  final ResponseFactory _rf;
  final Controller _controller;

  @override
  Future<HttpResponse> call(HttpRequest httpRequest) async {
    final matcher = RouteMatcher();
    _routing.match(httpRequest.uri, matcher);
    return (await ErrorHandling(CorsEnabled(matcher.getMatchedRouteOrElse(
                () => UnmatchedRoute(allowedMethods: [httpRequest.method]))))
            .dispatch(httpRequest, _controller))
        .convert(_rf);
  }
}
