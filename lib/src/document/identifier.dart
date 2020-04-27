import 'package:json_api/document.dart';

/// Resource identifier
///
/// Together with [Resource] forms the core of the Document model.
/// Identifiers are passed between the server and the client in the form
/// of [IdentifierObject]s.
class Identifier {
  /// Neither [type] nor [id] can be null or empty.
  Identifier(this.type, this.id) {
    ArgumentError.checkNotNull(type);
    ArgumentError.checkNotNull(id);
  }

  static Identifier of(Resource resource) =>
      Identifier(resource.type, resource.id);

  /// Resource type
  final String type;

  /// Resource id
  final String id;

  /// Returns true if the two identifiers have the same [type] and [id]
  bool equals(Identifier other) =>
      other != null &&
      other.runtimeType == Identifier &&
      other.type == type &&
      other.id == id;

  @override
  bool operator ==(other) => equals(other);

  @override
  int get hashCode => 0;
}
