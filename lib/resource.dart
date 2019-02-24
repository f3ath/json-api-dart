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
}
