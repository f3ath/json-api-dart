/// An object containing references to the source of the error.
class ErrorSource {
  const ErrorSource({this.pointer = '', this.parameter = ''});

  /// A JSON Pointer [RFC6901] to the associated entity in the request document.
  final String pointer;

  /// A string indicating which URI query parameter caused the error.
  final String parameter;

  bool get isEmpty => pointer.isEmpty && parameter.isEmpty;

  bool get isNotEmpty => !isEmpty;

  Map<String, String> toJson() => {
        if (parameter.isNotEmpty) 'parameter': parameter,
        if (pointer.isNotEmpty) 'pointer': pointer
      };
}
