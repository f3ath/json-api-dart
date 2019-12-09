/// The status code in the HTTP response
class StatusCode {
  /// The code
  final int code;

  const StatusCode(this.code);

  /// True for the requests processed asynchronously.
  /// @see https://jsonapi.org/recommendations/#asynchronous-processing).
  bool get isPending => code == 202;

  /// True for successfully processed requests
  bool get isSuccessful => code >= 200 && code < 300 && !isPending;

  /// True for failed requests
  bool get isFailed => !isSuccessful && !isPending;
}
