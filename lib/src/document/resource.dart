import 'package:json_api/src/document/identifier.dart';

/// Resource
///
/// Together with [Identifier] forms the core of the Document model.
/// Resources are passed between the server and the client in the form
/// of [ResourceObject]s.
class Resource {
  /// Resource type
  final String type;

  /// Resource id
  ///
  /// May be null for resources to be created on the server
  final String id;

  /// Resource attributes
  final attributes = <String, Object>{};

  /// to-one relationships
  final toOne = <String, Identifier>{};

  /// to-many relationships
  final toMany = <String, List<Identifier>>{};

  Resource(this.type, this.id,
      {Map<String, Object> attributes,
      Map<String, Identifier> toOne,
      Map<String, List<Identifier>> toMany}) {
    ArgumentError.checkNotNull(type, 'type');
    this.attributes.addAll(attributes ?? {});
    this.toOne.addAll(toOne ?? {});
    this.toMany.addAll(toMany ?? {});
  }

  /// Convert to Identifier
  Identifier toIdentifier() {
    if (id == null) throw StateError('Incomplete object: id is null');
    return Identifier(type, id);
  }

  @override
  String toString() => 'Resource(${type}:${id})';
}
