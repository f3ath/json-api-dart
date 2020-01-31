import 'package:json_api/src/http/normalize.dart';

/// The request which is sent by the client and received by the server
class HttpRequest {
  /// Requested URI
  final Uri uri;

  /// Request method, uppercase
  final String method;

  /// Request body
  final String body;

  /// Request headers. Unmodifiable. Lowercase keys
  final Map<String, String> headers;

  @override
  String toString() => 'HttpRequest($method $uri)';

  HttpRequest(String method, this.uri,
      {String body, Map<String, String> headers})
      : headers = normalize(headers),
        method = method.toUpperCase(),
        body = body ?? '';
}
