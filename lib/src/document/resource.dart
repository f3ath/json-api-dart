import 'package:json_api/src/document/document_exception.dart';
import 'package:json_api/src/document/identifier.dart';

/// Resource
///
/// Together with [Identifier] forms the core of the Document model.
/// Resources are passed between the server and the client in the form
/// of [ResourceObject]s.
class Resource {
  /// Resource type.
  final String type;

  /// Resource id.
  ///
  /// May be null for resources to be created on the server
  final String id;

  /// Unmodifiable map of attributes
  final Map<String, Object> attributes;

  /// Unmodifiable map of to-one relationships
  final Map<String, Identifier> toOne;

  /// Unmodifiable map of to-many relationships
  final Map<String, Iterable<Identifier>> toMany;

  /// Creates an instance of [Resource].
  /// The [type] can not be null.
  /// The [id] may be null for the resources to be created on the server.
  Resource(this.type, this.id,
      {Map<String, Object> attributes,
      Map<String, Identifier> toOne,
      Map<String, Iterable<Identifier>> toMany})
      : attributes = Map.unmodifiable(attributes ?? {}),
        toOne = Map.unmodifiable(toOne ?? {}),
        toMany = Map.unmodifiable(toMany ?? {}) {
    DocumentException.throwIfNull(type, "Resource 'type' must not be null");
  }

  /// Resource type and id combined
  String get key => '$type:$id';

  Identifier toIdentifier() {
    if (id == null) {
      throw StateError('Can not create an Identifier with id==null');
    }
    return Identifier(type, id);
  }

  @override
  String toString() => 'Resource($key $attributes)';

  /// Creates a new instance of the resource with replaced properties
  Resource replace(
          {String type,
          String id,
          Map<String, Object> attributes,
          Map<String, Identifier> toOne,
          Map<String, Iterable<Identifier>> toMany}) =>
      Resource(type ?? this.type, id ?? this.id,
          attributes: attributes ?? this.attributes,
          toOne: toOne ?? this.toOne,
          toMany: toMany ?? this.toMany);
}
