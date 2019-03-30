class StatusCode {
  final int code;

  StatusCode(this.code);

  bool get isPending => code == 202;

  bool get isSuccessful => code >= 200 && code < 300 && !isPending;

  bool get isFailed => !isSuccessful && !isPending;
}
