import 'dart:convert';

import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:json_api/http.dart';

/// A handler using the Dart's built-in http client
class DartHttp implements HttpHandler {
  DartHttp(this._client);

  @override
  Future<HttpResponse> call(HttpRequest request) async {
    final response = await _send(Request(request.method, request.uri)
      ..headers.addAll(request.headers)
      ..body = request.body);
    final responseBody =
        _encodingForHeaders(response.headers).decode(response.bodyBytes);
    return HttpResponse(
      response.statusCode,
      body: responseBody,
      headers: response.headers,
    );
  }

  final Client _client;

  Future<Response> _send(Request dartRequest) async =>
      Response.fromStream(await _client.send(dartRequest));

  /// Returns the encoding to use for a response with the given headers.
  ///
  /// Defaults to [UTF-8] if the headers don't specify a charset or if that
  /// charset is unknown.
  Encoding _encodingForHeaders(Map<String, String> headers) =>
      encodingForCharset(_contentTypeForHeaders(headers).parameters['charset']);

  /// Returns the [Encoding] that corresponds to [charset].
  ///
  /// Returns [fallback] if [charset] is null or if no [Encoding] was found that
  /// corresponds to [charset].
  Encoding encodingForCharset(String charset, [Encoding fallback = utf8]) {
    if (charset == null) return fallback;
    return Encoding.getByName(charset) ?? fallback;
  }

  /// Returns the [MediaType] object for the given headers's content-type.
  ///
  /// Defaults to `application/octet-stream`.
  MediaType _contentTypeForHeaders(Map<String, String> headers) {
    var contentType = headers['content-type'];
    if (contentType != null) return MediaType.parse(contentType);
    return MediaType('application', 'octet-stream');
  }
}
