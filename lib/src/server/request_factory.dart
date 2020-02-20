import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/src/server/request.dart';

/// TODO: Extract routing
class JsonApiRequestFactory {
  Request createFromHttp(HttpRequest request) {
    final s = request.uri.pathSegments;
    if (s.length == 1) {
      switch (request.method) {
        case 'GET':
          return FetchCollection(request.uri.queryParametersAll, s[0]);
        case 'POST':
          return CreateResource(
              s[0], ResourceData.fromJson(jsonDecode(request.body)).unwrap());
        default:
          throw MethodNotAllowedException(allow: ['GET', 'POST']);
      }
    } else if (s.length == 2) {
      switch (request.method) {
        case 'DELETE':
          return DeleteResource(s[0], s[1]);
        case 'GET':
          return FetchResource(s[0], s[1], request.uri.queryParametersAll);
        case 'PATCH':
          return UpdateResource(s[0], s[1],
              ResourceData.fromJson(jsonDecode(request.body)).unwrap());
        default:
          throw MethodNotAllowedException(allow: ['DELETE', 'GET', 'PATCH']);
      }
    } else if (s.length == 3) {
      switch (request.method) {
        case 'GET':
          return FetchRelated(s[0], s[1], s[2], request.uri.queryParametersAll);
        default:
          throw MethodNotAllowedException(allow: ['GET']);
      }
    } else if (s.length == 4 && s[2] == 'relationships') {
      switch (request.method) {
        case 'DELETE':
          return DeleteFromRelationship(s[0], s[1], s[3],
              ToMany.fromJson(jsonDecode(request.body)).unwrap());
        case 'GET':
          return FetchRelationship(
              s[0], s[1], s[3], request.uri.queryParametersAll);
        case 'PATCH':
          final rel = Relationship.fromJson(jsonDecode(request.body));
          if (rel is ToOne) {
            return ReplaceToOne(s[0], s[1], s[3], rel.unwrap());
          }
          if (rel is ToMany) {
            return ReplaceToMany(s[0], s[1], s[3], rel.unwrap());
          }
          throw IncompleteRelationshipException();
        case 'POST':
          return AddToRelationship(s[0], s[1], s[3],
              ToMany.fromJson(jsonDecode(request.body)).unwrap());
        default:
          throw MethodNotAllowedException(
              allow: ['DELETE', 'GET', 'PATCH', 'POST']);
      }
    }
    throw InvalidUriException();
  }
}

/// Thrown if HTTP method is not allowed for the given route
class MethodNotAllowedException implements Exception {
  final Iterable<String> allow;

  MethodNotAllowedException({this.allow = const []});
}

/// Thrown if the request URI can not be matched to a target
class InvalidUriException implements Exception {}

/// Thrown if the relationship object has no data
class IncompleteRelationshipException implements Exception {}
