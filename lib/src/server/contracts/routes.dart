class CollectionRoute {
  final String type;

  CollectionRoute(this.type);
}

class RelatedRoute {
  final String type;
  final String id;
  final String relationship;

  RelatedRoute(this.type, this.id, this.relationship);
}

class RelationshipRoute {
  final String type;
  final String id;
  final String relationship;

  RelationshipRoute(this.type, this.id, this.relationship);
}

class ResourceRoute {
  final String type;
  final String id;

  ResourceRoute(this.type, this.id);
}
