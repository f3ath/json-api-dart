mixin Identity {
  static bool same(Identity a, Identity b) => a.type == b.type && a.id == b.id;

  String get type;

  String get id;

  String get key => '$type:$id';
}
