import 'dart:convert';

import 'package:http_interop/http_interop.dart' as http;
import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/src/media_type.dart';

/// JSON:API response
class Response<D extends OutboundDocument> extends http.Response {
  Response(int statusCode, {D? document})
      : super(
            statusCode,
            document != null
                ? http.Body(jsonEncode(document), utf8)
                : http.Body.empty(),
            http.Headers({})) {
    if (document != null) {
      headers['Content-Type'] = [mediaType];
    }
  }

  static Response ok(OutboundDocument document) =>
      Response(StatusCode.ok, document: document);

  static Response noContent() => Response(StatusCode.noContent);

  static Response created(OutboundDocument document, String location) =>
      Response(StatusCode.created, document: document)
        ..headers['location'] = [location];

  static Response notFound([OutboundErrorDocument? document]) =>
      Response(StatusCode.notFound, document: document);

  static Response methodNotAllowed([OutboundErrorDocument? document]) =>
      Response(StatusCode.methodNotAllowed, document: document);

  static Response badRequest([OutboundErrorDocument? document]) =>
      Response(StatusCode.badRequest, document: document);

  static Response unsupportedMediaType([OutboundErrorDocument? document]) =>
      Response(StatusCode.unsupportedMediaType, document: document);

  static Response unacceptable([OutboundErrorDocument? document]) =>
      Response(StatusCode.unacceptable, document: document);
}
