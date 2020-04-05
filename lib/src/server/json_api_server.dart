import 'dart:async';
import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/resolvable.dart';
import 'package:json_api/src/server/target.dart';

/// A simple implementation of JSON:API server
class JsonApiServer implements HttpHandler {
  JsonApiServer(this._controller, {Routing routing})
      : _routing = routing ?? StandardRouting();

  final Routing _routing;
  final Controller _controller;

  @override
  Future<HttpResponse> call(HttpRequest httpRequest) async {
    final targetFactory = TargetFactory();
    _routing.match(httpRequest.uri, targetFactory);
    final target = targetFactory.target;

    if (target == null) {
      return HttpResponse(404,
          body: jsonEncode(Document.error([
            ErrorObject(
              status: '404',
              title: 'Not Found',
              detail: 'The requested URL does exist on the server',
            )
          ])));
    }

    if (!target.allowedMethods.contains(httpRequest.method)) {
      final allowed = target.allowedMethods.join(', ');
      return HttpResponse(405,
          body: jsonEncode(Document.error([
            ErrorObject(
              status: '405',
              title: 'Method Not Allowed',
              detail: 'Allowed methods: $allowed',
            )
          ])),
          headers: {'Allow': allowed});
    }

    try {
      final controllerRequest = target.convertRequest(httpRequest);
      final controllerResponse = await controllerRequest.resolve(_controller);
      return controllerResponse.convert();
    } on FormatException catch (e) {
      return HttpResponse(400,
          body: jsonEncode(Document.error([
            ErrorObject(
              status: '400',
              title: 'Bad Request',
              detail: 'Invalid JSON. ${e.message}',
            )
          ])));
    } on DocumentException catch (e) {
      return HttpResponse(400,
          body: jsonEncode(Document.error([
            ErrorObject(
              status: '400',
              title: 'Bad Request',
              detail: e.message,
            )
          ])));
    } on IncompleteRelationshipException catch (e) {
      return HttpResponse(400,
          body: jsonEncode(Document.error([
            ErrorObject(
              status: '400',
              title: 'Bad Request',
              detail: 'Incomplete relationship object',
            )
          ])));
    }
  }
}
