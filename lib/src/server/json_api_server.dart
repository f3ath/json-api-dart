import 'dart:async';
import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/server.dart';
import 'package:json_api/uri_design.dart';

class JsonApiServer implements HttpHandler {
  @override
  Future<HttpResponse> call(HttpRequest request) async {
    final response = await _do(request);
    final document = response.buildDocument(_factory, request.uri);
    return HttpResponse(response.statusCode,
        body: document == null ? null : jsonEncode(document),
        headers: response.buildHeaders(_uriDesign));
  }

  JsonApiServer(this._uriDesign, this._controller,
      {ResponseDocumentFactory documentFactory})
      : _factory = documentFactory ?? ResponseDocumentFactory(_uriDesign);

  final UriDesign _uriDesign;
  final JsonApiController _controller;
  final ResponseDocumentFactory _factory;

  Future<JsonApiResponse> _do(HttpRequest request) async {
    try {
      return await _dispatch(request);
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

  FutureOr<JsonApiResponse> _dispatch(HttpRequest request) async {
    final target = _uriDesign.matchTarget(request.uri);
    if (target is CollectionTarget) {
      switch (request.method) {
        case 'GET':
          return _controller.fetchCollection(request, target);
        case 'POST':
          return _controller.createResource(request, target,
              ResourceData.fromJson(jsonDecode(request.body)).unwrap());
        default:
          return _allow(['GET', 'POST']);
      }
    } else if (target is ResourceTarget) {
      switch (request.method) {
        case 'DELETE':
          return _controller.deleteResource(request, target);
        case 'GET':
          return _controller.fetchResource(request, target);
        case 'PATCH':
          return _controller.updateResource(request, target,
              ResourceData.fromJson(jsonDecode(request.body)).unwrap());
        default:
          return _allow(['DELETE', 'GET', 'PATCH']);
      }
    } else if (target is RelatedTarget) {
      switch (request.method) {
        case 'GET':
          return _controller.fetchRelated(request, target);
        default:
          return _allow(['GET']);
      }
    } else if (target is RelationshipTarget) {
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
          return _allow(['DELETE', 'GET', 'PATCH', 'POST']);
      }
    }
    return JsonApiResponse.notFound([
      JsonApiError(
          status: '404',
          title: 'Not Found',
          detail: 'The requested URL does exist on the server')
    ]);
  }

  JsonApiResponse _allow(Iterable<String> allow) =>
      JsonApiResponse.methodNotAllowed([
        JsonApiError(
            status: '405',
            title: 'Method Not Allowed',
            detail: 'Allowed methods: ${allow.join(', ')}')
      ], allow: allow);
}
