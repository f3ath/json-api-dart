import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/server/request.dart';

/// Converts HTTP requests to JSON:API requests
class RequestConverter {
  RequestConverter({RouteMatcher routeMatcher})
      : _matcher = routeMatcher ?? StandardRouting();
  final RouteMatcher _matcher;

  /// Creates a [Request] from [httpRequest]
  Request convert(HttpRequest httpRequest) {
    String type;
    String id;
    String rel;

    void setType(String t) {
      type = t;
    }

    void setTypeId(String t, String i) {
      type = t;
      id = i;
    }

    void setTypeIdRel(String t, String i, String r) {
      type = t;
      id = i;
      rel = r;
    }

    final uri = httpRequest.uri;
    if (_matcher.matchCollection(uri, setType)) {
      switch (httpRequest.method) {
        case 'GET':
          return FetchCollection(uri.queryParametersAll, type);
        case 'POST':
          return CreateResource(type,
              ResourceData.fromJson(jsonDecode(httpRequest.body)).unwrap());
        default:
          throw MethodNotAllowedException(['GET', 'POST']);
      }
    } else if (_matcher.matchResource(uri, setTypeId)) {
      switch (httpRequest.method) {
        case 'DELETE':
          return DeleteResource(type, id);
        case 'GET':
          return FetchResource(type, id, uri.queryParametersAll);
        case 'PATCH':
          return UpdateResource(type, id,
              ResourceData.fromJson(jsonDecode(httpRequest.body)).unwrap());
        default:
          throw MethodNotAllowedException(['DELETE', 'GET', 'PATCH']);
      }
    } else if (_matcher.matchRelated(uri, setTypeIdRel)) {
      switch (httpRequest.method) {
        case 'GET':
          return FetchRelated(type, id, rel, uri.queryParametersAll);
        default:
          throw MethodNotAllowedException(['GET']);
      }
    } else if (_matcher.matchRelationship(uri, setTypeIdRel)) {
      switch (httpRequest.method) {
        case 'DELETE':
          return DeleteFromRelationship(type, id, rel,
              ToMany.fromJson(jsonDecode(httpRequest.body)).unwrap());
        case 'GET':
          return FetchRelationship(type, id, rel, uri.queryParametersAll);
        case 'PATCH':
          final r = Relationship.fromJson(jsonDecode(httpRequest.body));
          if (r is ToOne) {
            final identifier = r.unwrap();
            if (identifier != null) {
              return ReplaceToOne(type, id, rel, identifier);
            }
            return DeleteToOne(type, id, rel);
          }
          if (r is ToMany) {
            return ReplaceToMany(type, id, rel, r.unwrap());
          }
          throw IncompleteRelationshipException();
        case 'POST':
          return AddToRelationship(type, id, rel,
              ToMany.fromJson(jsonDecode(httpRequest.body)).unwrap());
        default:
          throw MethodNotAllowedException(['DELETE', 'GET', 'PATCH', 'POST']);
      }
    }
    throw UnmatchedUriException();
  }
}

class RequestFactoryException implements Exception {}

/// Thrown if HTTP method is not allowed for the given route
class MethodNotAllowedException implements RequestFactoryException {
  MethodNotAllowedException(this.allow);

  /// List of allowed methods
  final Iterable<String> allow;
}

/// Thrown if the request URI can not be matched to a target
class UnmatchedUriException implements RequestFactoryException {}

/// Thrown if the relationship object has no data
class IncompleteRelationshipException implements RequestFactoryException {}
