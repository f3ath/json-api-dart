/// The target of a URI referring a resource collection
class CollectionTarget {
  /// Resource type
  final String type;

  const CollectionTarget(this.type);
}

/// The target of a URI referring to a single resource
class ResourceTarget {
  /// Resource type
  final String type;

  /// Resource id
  final String id;

  const ResourceTarget(this.type, this.id);
}

/// The target of a URI referring a related resource or collection
class RelatedTarget {
  /// Resource type
  final String type;

  /// Resource id
  final String id;

  /// Relationship name
  final String relationship;

  const RelatedTarget(this.type, this.id, this.relationship);
}

/// The target of a URI referring a relationship
class RelationshipTarget {
  /// Resource type
  final String type;

  /// Resource id
  final String id;

  /// Relationship name
  final String relationship;

  const RelationshipTarget(this.type, this.id, this.relationship);
}
