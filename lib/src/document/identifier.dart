/// Resource identifier
///
/// Together with [Resource] forms the core of the Document model.
/// Identifiers are passed between the server and the client in the form
/// of [IdentifierObject]s.
class Identifier {
  /// Resource type
  final String type;

  /// Resource id
  final String id;

  /// Neither [type] nor [id] can be null or empty.
  Identifier(this.type, this.id) {
    // TODO: check for emptiness
    ArgumentError.checkNotNull(id, 'id');
    ArgumentError.checkNotNull(type, 'type');
  }
}
