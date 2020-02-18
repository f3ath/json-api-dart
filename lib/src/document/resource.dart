import 'package:json_api/src/document/document_exception.dart';
import 'package:json_api/src/document/identifier.dart';

/// Resource
///
/// Together with [Identifiers] forms the core of the Document model.
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
  final Map<String, Identifiers> toOne;

  /// Unmodifiable map of to-many relationships
  final Map<String, Iterable<Identifiers>> toMany;

  /// Resource type and id combined
  String get key => '$type:$id';

  @override
  String toString() => 'Resource($key $attributes)';

  /// Creates an instance of [Resource].
  /// The [type] can not be null.
  /// The [id] may be null for the resources to be created on the server.
  Resource(this.type, this.id,
      {Map<String, Object> attributes,
      Map<String, Identifiers> toOne,
      Map<String, Iterable<Identifiers>> toMany})
      : attributes = Map.unmodifiable(attributes ?? {}),
        toOne = Map.unmodifiable(toOne ?? {}),
        toMany = Map.unmodifiable(
            (toMany ?? {}).map((k, v) => MapEntry(k, Set.of(v)))) {
    DocumentException.throwIfNull(type, "Resource 'type' must not be null");
  }
}

/// Resource to be created on the server. Does not have the id yet.
class NewResource extends Resource {
  NewResource(String type,
      {Map<String, Object> attributes,
      Map<String, Identifiers> toOne,
      Map<String, Iterable<Identifiers>> toMany})
      : super(type, null, attributes: attributes, toOne: toOne, toMany: toMany);
}
