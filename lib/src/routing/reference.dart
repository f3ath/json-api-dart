/// A reference to a resource collection
class CollectionReference {
  const CollectionReference(this.type);

  /// Resource type
  final String type;
}

/// A reference to a resource
class ResourceReference implements CollectionReference {
  const ResourceReference(this.type, this.id);

  @override
  final String type;

  /// Resource id
  final String id;
}

/// A reference to a resource relationship
class RelationshipReference implements ResourceReference {
  const RelationshipReference(this.type, this.id, this.relationship);

  @override
  final String type;

  @override
  final String id;

  /// Relationship name
  final String relationship;
}
