/// JSON:API identifier object
/// https://jsonapi.org/format/#document-resource-identifier-objects
class Identifier {
  final String type;
  final String id;

  Identifier(this.type, this.id) {
    ArgumentError.checkNotNull(id, 'id');
    ArgumentError.checkNotNull(type, 'type');
  }
}

/// Resource object
class Resource {
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

  Resource(this.type, this.id, {Map<String, Object> attributes,
      Map<String, Identifier> toOne, Map<String, List<Identifier>> toMany})
      : attributes = Map.unmodifiable(attributes),
        toOne = Map.unmodifiable(toOne ?? {}),
        toMany = Map.unmodifiable(toMany ?? {}) {
    ArgumentError.checkNotNull(type, 'type');
  }
}
