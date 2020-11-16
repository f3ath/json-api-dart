class MethodNotAllowed implements Exception {
  MethodNotAllowed(this.method);

  final String method;
}
