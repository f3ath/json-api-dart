class CollectionTarget {
  final String type;

  const CollectionTarget(this.type);
}

class ResourceTarget implements CollectionTarget {
  final String type;
  final String id;

  const ResourceTarget(this.type, this.id);
}

class RelationshipTarget implements ResourceTarget {
  final String type;
  final String id;
  final String relationship;

  const RelationshipTarget(this.type, this.id, this.relationship);
}
