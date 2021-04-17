import 'dart:convert';

import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:json_api/http.dart';

/// Handler which relies on the built-in Dart HTTP client.
/// It is the developer's responsibility to instantiate the client and
/// call `close()` on it in the end pf the application lifecycle.
class PersistentHandler {
  /// Creates a new instance of the handler. Do not forget to call `close()` on
  /// the [client] when it's not longer needed.
  PersistentHandler(this.client, {this.defaultEncoding = utf8});

  final Client client;
  final Encoding defaultEncoding;

  Future<HttpResponse> handle(HttpRequest request) async {
    final response = await Response.fromStream(
        await client.send(Request(request.method, request.uri)
          ..headers.addAll(request.headers)
          ..body = request.body));
    final responseBody =
        _encodingForHeaders(response.headers).decode(response.bodyBytes);
    return HttpResponse(response.statusCode, body: responseBody)
      ..headers.addAll(response.headers);
  }

  /// Returns the encoding to use for a response with the given headers.
  ///
  /// Defaults to [defaultEncoding] if the headers don't specify a charset or if that
  /// charset is unknown.
  Encoding _encodingForHeaders(Map<String, String> headers) =>
      _encodingForCharset(
          _contentTypeForHeaders(headers).parameters['charset']);

  /// Returns the [Encoding] that corresponds to [charset].
  ///
  /// Returns [defaultEncoding] if [charset] is null or if no [Encoding] was found that
  /// corresponds to [charset].
  Encoding _encodingForCharset(String? charset) {
    if (charset == null) return defaultEncoding;
    return Encoding.getByName(charset) ?? defaultEncoding;
  }

  /// Returns the [MediaType] object for the given headers's content-type.
  ///
  /// Defaults to `application/octet-stream`.
  MediaType _contentTypeForHeaders(Map<String, String> headers) {
    final contentType = headers['content-type'];
    if (contentType != null) return MediaType.parse(contentType);
    return MediaType('application', 'octet-stream');
  }
}
