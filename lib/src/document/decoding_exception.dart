/// Indicates an error happened while converting JSON data into a JSON:API object.
class DecodingException<T> implements Exception {
  final Object json;

  DecodingException(this.json);

  @override
  String toString() => 'Can not decode $T from JSON: $json';
}
