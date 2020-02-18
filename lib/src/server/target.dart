
abstract class Target {}

/// The target of a URI referring a resource collection
class CollectionTarget implements Target {
  /// Resource type
  final String type;

  const CollectionTarget(this.type);
}

/// The target of a URI referring to a single resource
class ResourceTarget implements Target {
  /// Resource type
  final String type;

  /// Resource id
  final String id;

  const ResourceTarget(this.type, this.id);
}

/// The target of a URI referring a related resource or collection
class RelatedTarget implements Target {
  /// Resource type
  final String type;

  /// Resource id
  final String id;

  /// Relationship name
  final String relationship;

  const RelatedTarget(this.type, this.id, this.relationship);
}

/// The target of a URI referring a relationship
class RelationshipTarget implements Target {
  /// Resource type
  final String type;

  /// Resource id
  final String id;

  /// Relationship name
  final String relationship;

  const RelationshipTarget(this.type, this.id, this.relationship);
}
