import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/src/nullable.dart';

/// JSON:API response
class Response<D extends OutboundDocument> extends HttpResponse {
  Response(int statusCode, {this.document}) : super(statusCode) {
    if (document != null) {
      headers['Content-Type'] = MediaType.jsonApi;
    }
  }

  final D? document;

  @override
  String get body => nullable(jsonEncode)(document) ?? '';

  static Response ok(OutboundDocument document) =>
      Response(StatusCode.ok, document: document);

  static Response noContent() => Response(StatusCode.noContent);

  static Response created(OutboundDocument document, String location) =>
      Response(StatusCode.created, document: document)
        ..headers['location'] = location;

  static Response notFound([OutboundErrorDocument? document]) =>
      Response(StatusCode.notFound, document: document);

  static Response methodNotAllowed([OutboundErrorDocument? document]) =>
      Response(StatusCode.methodNotAllowed, document: document);

  static Response badRequest([OutboundErrorDocument? document]) =>
      Response(StatusCode.badRequest, document: document);
}
