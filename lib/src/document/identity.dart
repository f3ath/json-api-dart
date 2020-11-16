/// Resource identity.
mixin Identity {
  static const separator = ':';

  /// Resource type
  String get type;

  /// Resource id
  String get id;

  /// Compound key, uniquely identifying the resource
  String get key => '$type$separator$id';
}
