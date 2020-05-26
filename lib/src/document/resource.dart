import 'package:json_api/src/document/identifier.dart';

/// Resource
///
/// Together with [Identifier] forms the core of the Document model.
/// Resources are passed between the server and the client in the form
/// of [ResourceObject]s.
class Resource {
  /// Creates an instance of [Resource].
  /// The [type] can not be null.
  /// The [id] may be null for the resources to be created on the server.
  Resource(this.type, this.id,
      {Map<String, Object> attributes,
      Map<String, Identifier> toOne,
      Map<String, List<Identifier>> toMany})
      : attributes = Map.unmodifiable(attributes ?? const {}),
        toOne = Map.unmodifiable(toOne ?? const {}),
        toMany = Map.unmodifiable(
            (toMany ?? {}).map((k, v) => MapEntry(k, Set.of(v).toList()))) {
    ArgumentError.notNull(type);
  }

  /// Resource type
  final String type;

  /// Resource id
  ///
  /// May be null for resources to be created on the server
  final String id;

  /// Unmodifiable map of attributes
  final Map<String, Object> attributes;

  /// Unmodifiable map of to-one relationships
  final Map<String, Identifier> toOne;

  /// Unmodifiable map of to-many relationships
  final Map<String, List<Identifier>> toMany;

  /// Resource type and id combined
  String get key => '$type:$id';

  @override
  String toString() => 'Resource($key $attributes)';
}

/// Resource to be created on the server. Does not have the id yet
class NewResource extends Resource {
  NewResource(String type,
      {Map<String, Object> attributes,
      Map<String, Identifier> toOne,
      Map<String, List<Identifier>> toMany})
      : super(type, null, attributes: attributes, toOne: toOne, toMany: toMany);
}
