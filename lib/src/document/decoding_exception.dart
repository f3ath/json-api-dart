/// Indicates an error happened while converting JSON data into a JSON:API object.
class DecodingException implements Exception {
  final String message;

  DecodingException(this.message);
}
