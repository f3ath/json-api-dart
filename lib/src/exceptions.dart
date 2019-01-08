class JsonApiClientException implements Exception {
  final String message;

  JsonApiClientException(this.message);
}

/// Thrown when the client receives a response with the
/// Content-Type different from [Document.mediaType]
class InvalidContentTypeException extends JsonApiClientException {
  InvalidContentTypeException(String message) : super(message);
}
