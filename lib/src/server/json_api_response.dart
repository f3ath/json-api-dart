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
      JsonApiResponse(StatusCode.ok, document: document);

  static JsonApiResponse noContent() => JsonApiResponse(StatusCode.noContent);

  static JsonApiResponse created(OutboundDocument document, String location) =>
      JsonApiResponse(StatusCode.created, document: document)..headers['location'] = location;

  static JsonApiResponse notFound([OutboundErrorDocument? document]) =>
      JsonApiResponse(StatusCode.notFound, document: document);

  static JsonApiResponse methodNotAllowed([OutboundErrorDocument? document]) =>
      JsonApiResponse(StatusCode.methodNotAllowed, document: document);

  static JsonApiResponse badRequest([OutboundErrorDocument? document]) =>
      JsonApiResponse(StatusCode.badRequest, document: document);
}
