class Identifier {
  /// Resource type
  final String type;

  /// Resource id
  final String id;

  Identifier(this.type, this.id) {
    ArgumentError.checkNotNull(id, 'id');
    ArgumentError.checkNotNull(type, 'type');
  }
}
