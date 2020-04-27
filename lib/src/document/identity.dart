mixin Identity {
  String get type;

  String get id;

  String get key => '$type:$id';
}
