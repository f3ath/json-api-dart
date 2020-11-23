import 'dart:convert';

import 'package:json_api/http.dart';
import 'package:json_api/src/nullable.dart';

/// JSON:API response
class Response extends HttpResponse {
  Response(int statusCode, {Object /*?*/ document})
      : super(statusCode, body: nullable(jsonEncode)(document) ?? '') {
    if (body.isNotEmpty) headers['content-type'] = MediaType.jsonApi;
  }

  static Response ok(Object document) => Response(200, document: document);

  static Response noContent() => Response(204);

  static Response created(Object document, String location) =>
      Response(201, document: document)..headers['location'] = location;

  static Response notFound({Object /*?*/ document}) =>
      Response(404, document: document);

  static Response methodNotAllowed({Object /*?*/ document}) =>
      Response(405, document: document);

  static Response badRequest({Object /*?*/ document}) =>
      Response(400, document: document);

  static Response internalServerError({Object /*?*/ document}) =>
      Response(500, document: document);
}
