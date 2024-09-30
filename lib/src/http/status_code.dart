extension type StatusCode(int value) {
  static const ok = 200;
  static const created = 201;
  static const accepted = 202;
  static const noContent = 204;
  static const badRequest = 400;
  static const notFound = 404;
  static const methodNotAllowed = 405;
  static const notAcceptable = 406;
  static const conflict = 409;
  static const unsupportedMediaType = 415;
  static const internalServerError = 500;

  /// True for the requests processed asynchronously.
  /// @see https://jsonapi.org/recommendations/#asynchronous-processing).
  bool get isPending => value == accepted;

  /// True for successfully processed requests
  bool get isSuccessful => value >= ok && value < 300 && !isPending;

  /// True for failed requests (i.e. neither successful nor pending)
  bool get isFailed => !isSuccessful && !isPending;
}
