/// Resource identity.
mixin Identity {
  static const separator = ':';

  /// Makes a string key from [type] and [id]
  static String makeKey(String type, String id) => '$type$separator$id';

  /// Splits the key into the type and id. Returns a list of 2 elements.
  static List<String> split(String key) => key.split(separator);

  /// Resource type
  String get type;

  /// Resource id
  String get id;

  /// Compound key, uniquely identifying the resource
  String get key => makeKey(type, id);
}
