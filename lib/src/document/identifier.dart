import 'package:json_api/document.dart';
import 'package:json_api/src/document/document_exception.dart';

/// Resource identifier
///
/// Together with [Resource] forms the core of the Document model.
/// Identifiers are passed between the server and the client in the form
/// of [IdentifierObject]s.
class Identifiers {
  /// Resource type
  final String type;

  /// Resource id
  final String id;

  /// Neither [type] nor [id] can be null or empty.
  Identifiers(this.type, this.id) {
    DocumentException.throwIfNull(id, "Identifier 'id' must not be null");
    DocumentException.throwIfNull(type, "Identifier 'type' must not be null");
  }

  static Identifiers of(Resource resource) =>
      Identifiers(resource.type, resource.id);

  /// Returns true if the two identifiers have the same [type] and [id]
  bool equals(Identifiers other) =>
      other != null &&
      other.runtimeType == Identifiers &&
      other.type == type &&
      other.id == id;

  @override
  String toString() => 'Identifier($type:$id)';

  @override
  bool operator ==(other) => equals(other);

  @override
  int get hashCode => 0;
}
