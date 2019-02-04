class ParseError implements Exception {
  final Type type;
  final Object json;

  ParseError(this.type, this.json);

  @override
  String toString() => 'Can not parse $type from $json';
}
