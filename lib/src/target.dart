class CollectionTarget {
  final String type;

  const CollectionTarget(this.type);

  @override
  bool operator ==(other) => other is CollectionTarget && other.type == type;
}

class ResourceTarget implements CollectionTarget {
  final String type;
  final String id;

  const ResourceTarget(this.type, this.id);

  @override
  bool operator ==(other) =>
      other is ResourceTarget && other.type == type && other.id == id;
}

class RelationshipTarget implements ResourceTarget {
  final String type;
  final String id;
  final String relationship;

  const RelationshipTarget(this.type, this.id, this.relationship);

  @override
  bool operator ==(other) =>
      other is RelationshipTarget &&
      other.type == type &&
      other.id == id &&
      other.relationship == relationship;
}
