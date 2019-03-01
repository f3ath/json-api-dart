/// The core of the Resource Identifier object
/// https://jsonapi.org/format/#document-resource-identifier-objects
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
