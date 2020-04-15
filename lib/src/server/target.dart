class CollectionTarget {
  CollectionTarget(this.type);

  final String type;
}

class ResourceTarget implements CollectionTarget {
  ResourceTarget(this.type, this.id);

  @override
  final String type;

  final String id;
}

class RelationshipTarget implements ResourceTarget {
  RelationshipTarget(this.type, this.id, this.relationship);

  @override
  final String type;

  @override
  final String id;

  final String relationship;
}
