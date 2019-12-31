/// JSON:API HTTP request
class JsonApiRequest {
  JsonApiRequest(this.method, this.requestedUri, this.body);

  /// Requested URI
  final Uri requestedUri;

  /// JSON-decoded body, may be null
  final Object body;

  /// HTTP method
  final String method;
}
