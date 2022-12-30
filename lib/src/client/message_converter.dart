import 'dart:convert';

import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:json_api/http.dart';

/// Converts HTTP messages to and from to ones used by the `http` package.
class MessageConverter {
  /// Creates an instance of the converter.
  ///
  /// Pass [defaultResponseEncoding] to use in cases when the server does
  /// not specify the encoding.
  MessageConverter({Encoding defaultResponseEncoding = utf8})
      : _defaultResponseEncoding = defaultResponseEncoding;

  final Encoding _defaultResponseEncoding;

  /// Converts [HttpRequest] to [Request].
  Request request(HttpRequest request) {
    final converted = Request(request.method, request.uri);
    final hasBody = !(request.isGet || request.isOptions);
    if (hasBody) {
      // The Request would set the content-type header if the body is assigned
      // a value (even an empty string). We want to avoid this extra header for
      // GET and OPTIONS requests.
      // See https://github.com/dart-lang/http/issues/841
      converted.body = request.body;
    }
    converted.headers.addAll(request.headers);
    return converted;
  }

  /// Converts [Response] to [HttpResponse].
  HttpResponse response(Response response) {
    final encoding = _encodingForHeaders(response.headers);
    final body = encoding.decode(response.bodyBytes);
    return HttpResponse(response.statusCode, body: body)
      ..headers.addAll(response.headers);
  }

  /// Returns the [Encoding] that corresponds to [charset].
  ///
  /// Returns [defaultResponseEncoding] if [charset] is null or if no [Encoding]
  /// was found that corresponds to [charset].
  Encoding _encodingForCharset(String? charset) {
    if (charset == null) return _defaultResponseEncoding;
    return Encoding.getByName(charset) ?? _defaultResponseEncoding;
  }

  /// Returns the [MediaType] object for the given content-type.
  ///
  /// Defaults to `application/octet-stream`.
  MediaType _mediaType(String? contentType) {
    if (contentType != null) return MediaType.parse(contentType);
    return MediaType('application', 'octet-stream');
  }

  /// Returns the encoding to use for a response with the given headers.
  ///
  /// Defaults to [defaultEncoding] if the headers don't specify the charset
  /// or if that charset is unknown.
  Encoding _encodingForHeaders(Map<String, String> headers) {
    final mediaType = _mediaType(headers['content-type']);
    final charset = mediaType.parameters['charset'];
    return _encodingForCharset(charset);
  }
}
