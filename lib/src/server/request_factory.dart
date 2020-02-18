import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/src/server/json_api_request.dart';
import 'package:json_api/src/server/json_api_response.dart';

class JsonApiRequestFactory {
  JsonApiRequest getJsonApiRequest(HttpRequest request) {
    try {
      return _convert(request);
    } on FormatException catch (e) {
      return PredefinedResponse(JsonApiResponse.badRequest([
        JsonApiError(
            status: '400',
            title: 'Bad request',
            detail: 'Invalid JSON. ${e.message}')
      ]));
    } on DocumentException catch (e) {
      return PredefinedResponse(JsonApiResponse.badRequest([
        JsonApiError(status: '400', title: 'Bad request', detail: e.message)
      ]));
    }
  }

  JsonApiRequest _convert(HttpRequest request) {
    final s = request.uri.pathSegments;
    if (s.length == 1) {
      switch (request.method) {
        case 'GET':
          return FetchCollection(request.uri.queryParametersAll, s[0]);
        case 'POST':
          return CreateResource(
              s[0], ResourceData.fromJson(jsonDecode(request.body)).unwrap());
        default:
          return _methodNotAllowed(['GET', 'POST']);
      }
    } else if (s.length == 2) {
      switch (request.method) {
        case 'DELETE':
          return DeleteResource(s[0], s[1]);
        case 'GET':
          return FetchResource(s[0], s[1], request.uri.queryParametersAll);
        case 'PATCH':
          return UpdateResourceRequest(s[0], s[1],
              ResourceData.fromJson(jsonDecode(request.body)).unwrap());
        default:
          return _methodNotAllowed(['DELETE', 'GET', 'PATCH']);
      }
    } else if (s.length == 3) {
      switch (request.method) {
        case 'GET':
          return FetchRelated(s[0], s[1], s[2], request.uri.queryParametersAll);
        default:
          return _methodNotAllowed(['GET']);
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
          return PredefinedResponse(JsonApiResponse.badRequest([
            JsonApiError(
                status: '400',
                title: 'Bad request',
                detail: 'Incomplete relationship object')
          ]));
        case 'POST':
          return AddToRelationship(s[0], s[1], s[3],
              ToMany.fromJson(jsonDecode(request.body)).unwrap());
        default:
          return _methodNotAllowed(['DELETE', 'GET', 'PATCH', 'POST']);
      }
    }
    return PredefinedResponse(JsonApiResponse.notFound([
      JsonApiError(
          status: '404',
          title: 'Not Found',
          detail: 'The requested URL does exist on the server')
    ]));
  }

  JsonApiRequest _methodNotAllowed(Iterable<String> allow) =>
      PredefinedResponse(JsonApiResponse.methodNotAllowed([
        JsonApiError(
            status: '405',
            title: 'Method Not Allowed',
            detail: 'Allowed methods: ${allow.join(', ')}')
      ], allow: allow));
}
