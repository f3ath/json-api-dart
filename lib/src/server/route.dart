import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/request.dart';
import 'package:json_api/src/server/response.dart';

abstract class Route {
  List<String> get allowedMethods;

  Future<Response> dispatch(HttpRequest request, Controller controller);
}

class UnmatchedRoute implements Route {
  UnmatchedRoute({this.allowedMethods = const []});

  @override
  final allowedMethods;

  @override
  Future<Response> dispatch(HttpRequest request, Controller controller) async =>
      ErrorResponse(404, [
        ErrorObject(
          status: '404',
          title: 'Not Found',
          detail: 'The requested URL does exist on the server',
        )
      ]);
}

class ErrorHandling implements Route {
  ErrorHandling(this._route);

  final Route _route;

  @override
  List<String> get allowedMethods => _route.allowedMethods;

  @override
  Future<Response> dispatch(HttpRequest request, Controller controller) async {
    if (!_route.allowedMethods.contains(request.method)) {
      return ExtraHeaders(
          ErrorResponse(405, []), {'Allow': _route.allowedMethods.join(', ')});
    }
    try {
      return await _route.dispatch(request, controller);
    } on FormatException catch (e) {
      return ErrorResponse(400, [
        ErrorObject(
          status: '400',
          title: 'Bad Request',
          detail: 'Invalid JSON. ${e.message}',
        )
      ]);
    } on DocumentException catch (e) {
      return ErrorResponse(400, [
        ErrorObject(
          status: '400',
          title: 'Bad Request',
          detail: e.message,
        )
      ]);
    } on IncompleteRelationshipException {
      return ErrorResponse(400, [
        ErrorObject(
          status: '400',
          title: 'Bad Request',
          detail: 'Incomplete relationship object',
        )
      ]);
    }
  }
}

class CorsEnabled<T extends CollectionTarget> implements Route {
  CorsEnabled(this._route);

  final Route _route;

  @override
  List<String> get allowedMethods => _route.allowedMethods + ['OPTIONS'];

  @override
  Future<Response> dispatch(HttpRequest request, Controller controller) async {
    if (request.isOptions) {
      return ExtraHeaders(NoContentResponse(), {
        'Access-Control-Allow-Methods': allowedMethods.join(', '),
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Max-Age': '3600',
      });
    }
    return ExtraHeaders(await _route.dispatch(request, controller),
        {'Access-Control-Allow-Origin': '*'});
  }
}

class CollectionRoute implements Route {
  CollectionRoute(this._target);

  final CollectionTarget _target;

  @override
  final allowedMethods = ['GET', 'POST'];

  @override
  Future<Response> dispatch(HttpRequest request, Controller controller) {
    final r = Request(request.uri, _target);
    if (request.isGet) {
      return controller.fetchCollection(r);
    }
    if (request.isPost) {
      return controller.createResource(
          r, ResourceData.fromJson(jsonDecode(request.body)).unwrap());
    }
    throw ArgumentError();
  }
}

class ResourceRoute implements Route {
  ResourceRoute(this._target);

  final ResourceTarget _target;

  @override
  final allowedMethods = ['DELETE', 'GET', 'PATCH'];

  @override
  Future<Response> dispatch(HttpRequest request, Controller controller) {
    final r = Request(request.uri, _target);
    if (request.isDelete) {
      return controller.deleteResource(r);
    }
    if (request.isGet) {
      return controller.fetchResource(r);
    }
    if (request.isPatch) {
      return controller.updateResource(
          r, ResourceData.fromJson(jsonDecode(request.body)).unwrap());
    }
    throw ArgumentError();
  }
}

class RelatedRoute implements Route {
  RelatedRoute(this._target);

  final RelatedTarget _target;

  @override
  final allowedMethods = ['GET'];

  @override
  Future<Response> dispatch(HttpRequest request, Controller controller) {
    if (request.isGet) {
      return controller.fetchRelated(Request(request.uri, _target));
    }
    throw ArgumentError();
  }
}

class RelationshipRoute implements Route {
  RelationshipRoute(this._target);

  final RelationshipTarget _target;

  @override
  final allowedMethods = ['DELETE', 'GET', 'PATCH', 'POST'];

  @override
  Future<Response> dispatch(HttpRequest request, Controller controller) {
    final r = Request(request.uri, _target);
    if (request.isDelete) {
      return controller.deleteFromRelationship(
          r, ToManyObject.fromJson(jsonDecode(request.body)).linkage);
    }
    if (request.isGet) {
      return controller.fetchRelationship(r);
    }
    if (request.isPatch) {
      final rel = RelationshipObject.fromJson(jsonDecode(request.body));
      if (rel is ToOneObject) {
        return controller.replaceToOne(r, rel.linkage);
      }
      if (rel is ToManyObject) {
        return controller.replaceToMany(r, rel.linkage);
      }
      throw IncompleteRelationshipException();
    }
    if (request.isPost) {
      return controller.addToRelationship(
          r, ToManyObject.fromJson(jsonDecode(request.body)).linkage);
    }
    throw ArgumentError();
  }
}

/// Thrown if the relationship object has no data
class IncompleteRelationshipException implements Exception {}
