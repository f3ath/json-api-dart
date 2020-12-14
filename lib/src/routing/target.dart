class Target {
  const Target(this.type);

  final String type;
}

class ResourceTarget implements Target {
  const ResourceTarget(this.type, this.id);

  @override
  final String type;
  final String id;
}

class RelatedTarget implements ResourceTarget {
  const RelatedTarget(this.type, this.id, this.relationship);

  @override
  final String type;
  @override
  final String id;

  final String relationship;
}

class RelationshipTarget implements ResourceTarget {
  const RelationshipTarget(this.type, this.id, this.relationship);

  @override
  final String type;
  @override
  final String id;

  final String relationship;
}
