import 'package:json_api/src/http/method.dart';

/// The request which is sent by the client and received by the server
class HttpRequest {
  HttpRequest(String method, Uri uri,
      {String body, Map<String, String> headers})
      : this._(method.toUpperCase(), uri, _normalize(headers), body ?? '');

  HttpRequest._(this.method, this.uri, this.headers, this.body);

  /// Requested URI
  final Uri uri;

  /// Request method, uppercase
  final String method;

  /// Request body
  final String body;

  /// Request headers. Unmodifiable. Lowercase keys
  final Map<String, String> headers;

  static Map<String, String> _normalize(Map<String, String> headers) =>
      Map.unmodifiable(
          (headers ?? {}).map((k, v) => MapEntry(k.toLowerCase(), v)));

  HttpRequest withHeaders(Map<String, String> headers) =>
      HttpRequest._(method, uri, _normalize(headers), body);

  HttpRequest withUri(Uri uri) => HttpRequest._(method, uri, headers, body);

  bool get isGet => method == Method.GET;

  bool get isPost => method == Method.POST;

  bool get isDelete => method == Method.DELETE;

  bool get isPatch => method == Method.PATCH;

  bool get isOptions => method == Method.OPTIONS;
}
