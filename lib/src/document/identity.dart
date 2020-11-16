/// Resource identity.
mixin Identity {
  /// Resource type
  String get type;

  /// Resource id
  String get id;

  /// Compound key, uniquely identifying the resource
  String get key => '$type:$id';
}
