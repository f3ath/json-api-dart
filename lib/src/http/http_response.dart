/// The response sent by the server and received by the client
class HttpResponse {
  /// Response status code
  final int statusCode;

  /// Response body
  final String body;

  /// Response headers. Unmodifiable. Lowercase keys
  final Map<String, String> headers;

  HttpResponse(this.statusCode, {String body, Map<String, String> headers})
      : headers = Map.unmodifiable(
            (headers ?? {}).map((k, v) => MapEntry(k.toLowerCase(), v))),
        body = body ?? '';
}
