mixin Identity {
  static final delimiter = ':';

  String get type;

  String get id;

  String get key => '$type$delimiter$id';

  @override
  String toString() => key;
}
