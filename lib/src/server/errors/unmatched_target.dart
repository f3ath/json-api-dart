class UnmatchedTarget implements Exception {
  UnmatchedTarget(this.uri);

  final Uri uri;
}
