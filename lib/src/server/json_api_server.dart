import 'dart:async';
import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/target.dart';

class JsonApiServer implements HttpHandler {
  @override
  Future<HttpResponse> call(HttpRequest request) async {
    final response = await _do(request);
    response.buildDocument(_factory, request.uri);
    final document = _factory.build();

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

  Future<JsonApiResponse> _do(HttpRequest request) async {
    try {
      return await RequestDispatcher(_controller).dispatch(request);
    } on JsonApiResponse catch (e) {
      return e;
    } on FormatException catch (e) {
      return JsonApiResponse.badRequest([
        JsonApiError(
            status: '400',
            title: 'Bad request',
            detail: 'Invalid JSON. ${e.message}')
      ]);
    } on DocumentException catch (e) {
      return JsonApiResponse.badRequest([
        JsonApiError(status: '400', title: 'Bad request', detail: e.message)
      ]);
    }
  }
}

class RequestDispatcher {
  FutureOr<JsonApiResponse> dispatch(HttpRequest request) async {
    final s = request.uri.pathSegments;
    if (s.length == 1) {
      final target = CollectionTarget(s[0]);
      switch (request.method) {
        case 'GET':
          return _controller.fetchCollection(request, target);
        case 'POST':
          return _controller.createResource(request, target,
              ResourceData.fromJson(jsonDecode(request.body)).unwrap());
        default:
          return _methodNotAllowed(['GET', 'POST']);
      }
    } else if (s.length == 2) {
      final target = ResourceTarget(s[0], s[1]);
      switch (request.method) {
        case 'DELETE':
          return _controller.deleteResource(request, target);
        case 'GET':
          return _controller.fetchResource(request, target);
        case 'PATCH':
          return _controller.updateResource(request, target,
              ResourceData.fromJson(jsonDecode(request.body)).unwrap());
        default:
          return _methodNotAllowed(['DELETE', 'GET', 'PATCH']);
      }
    } else if (s.length == 3) {
      switch (request.method) {
        case 'GET':
          return _controller.fetchRelated(
              request, RelatedTarget(s[0], s[1], s[2]));
        default:
          return _methodNotAllowed(['GET']);
      }
    } else if (s.length == 4 && s[2] == 'relationships') {
      final target = RelationshipTarget(s[0], s[1], s[3]);
      switch (request.method) {
        case 'DELETE':
          return _controller.deleteFromRelationship(request, target,
              ToMany.fromJson(jsonDecode(request.body)).unwrap());
        case 'GET':
          return _controller.fetchRelationship(request, target);
        case 'PATCH':
          final rel = Relationship.fromJson(jsonDecode(request.body));
          if (rel is ToOne) {
            return _controller.replaceToOne(request, target, rel.unwrap());
          }
          if (rel is ToMany) {
            return _controller.replaceToMany(request, target, rel.unwrap());
          }
          return JsonApiResponse.badRequest([
            JsonApiError(
                status: '400',
                title: 'Bad request',
                detail: 'Incomplete relationship object')
          ]);
        case 'POST':
          return _controller.addToRelationship(request, target,
              ToMany.fromJson(jsonDecode(request.body)).unwrap());
        default:
          return _methodNotAllowed(['DELETE', 'GET', 'PATCH', 'POST']);
      }
    }
    return JsonApiResponse.notFound([
      JsonApiError(
          status: '404',
          title: 'Not Found',
          detail: 'The requested URL does exist on the server')
    ]);
  }

  RequestDispatcher(this._controller);

  final JsonApiController _controller;

  JsonApiResponse _methodNotAllowed(Iterable<String> allow) =>
      JsonApiResponse.methodNotAllowed([
        JsonApiError(
            status: '405',
            title: 'Method Not Allowed',
            detail: 'Allowed methods: ${allow.join(', ')}')
      ], allow: allow);
}
