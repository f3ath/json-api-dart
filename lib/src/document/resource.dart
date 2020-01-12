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
  final Map<String, List<Identifier>> toMany;

  /// Creates an instance of [Resource].
  /// The [type] can not be null.
  /// The [id] may be null for the resources to be created on the server.
  Resource(this.type, this.id,
      {Map<String, Object> attributes,
      Map<String, Identifier> toOne,
      Map<String, List<Identifier>> toMany})
      : attributes = Map.unmodifiable(attributes ?? {}),
        toOne = Map.unmodifiable(toOne ?? {}),
        toMany = Map.unmodifiable(toMany ?? {}) {
    ArgumentError.checkNotNull(type, 'type');
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

  /// Returns true if this resource has the same [key] and all [attributes]
  /// and relationships as the [other] (not necessarily with the same values).
  /// This method can be used to chose between 200 and 204 in PATCH requests.
  /// See https://jsonapi.org/format/#crud-updating-responses
  bool hasAllMembersOf(Resource other) =>
      other.key == key &&
      other.attributes.keys.every(attributes.containsKey) &&
      other.toOne.keys.every(toOne.containsKey) &&
      other.toMany.keys.every(toMany.containsKey);

  /// Adds all attributes and relationships from the [other] resource which
  /// are not present in this resource. Returns a new instance.
  Resource withExtraMembersFrom(Resource other) => Resource(type, id,
      attributes: _merge(other.attributes, attributes),
      toOne: _merge(other.toOne, toOne),
      toMany: _merge(other.toMany, toMany));

  /// Creates a new instance of the resource with replaced properties
  Resource replace(
          {String type,
          String id,
          Map<String, Object> attributes,
          Map<String, Identifier> toOne,
          Map<String, List<Identifier>> toMany}) =>
      Resource(type ?? this.type, id ?? this.id,
          attributes: attributes ?? this.attributes,
          toOne: toOne ?? this.toOne,
          toMany: toMany ?? this.toMany);

  Map<K, V> _merge<K, V>(Map<K, V> source, Map<K, V> dest) {
    final copy = {...dest};
    source.forEach((k, v) => copy.putIfAbsent(k, () => v));
    return copy;
  }
}
