import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/src/nullable.dart';

/// JSON:API response
class JsonApiResponse<D extends OutboundDocument> extends HttpResponse {
  JsonApiResponse(int statusCode, {this.document}) : super(statusCode) {
    if (document != null) {
      headers['Content-Type'] = MediaType.jsonApi;
    }
  }

  final D? document;

  @override
  String get body => nullable(jsonEncode)(document) ?? '';

  static JsonApiResponse ok(OutboundDocument document) =>
      JsonApiResponse(200, document: document);

  static JsonApiResponse noContent() => JsonApiResponse(204);

  static JsonApiResponse created(OutboundDocument document, String location) =>
      JsonApiResponse(201, document: document)..headers['location'] = location;

  static JsonApiResponse notFound([OutboundErrorDocument? document]) =>
      JsonApiResponse(404, document: document);

  static JsonApiResponse methodNotAllowed([OutboundErrorDocument? document]) =>
      JsonApiResponse(405, document: document);

  static JsonApiResponse badRequest([OutboundErrorDocument? document]) =>
      JsonApiResponse(400, document: document);

  static JsonApiResponse internalServerError(
          [OutboundErrorDocument? document]) =>
      JsonApiResponse(500, document: document);
}
