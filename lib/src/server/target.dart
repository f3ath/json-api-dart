abstract class CollectionTarget {
  String get type;
}

abstract class ResourceTarget implements CollectionTarget {
  String get id;
}

abstract class RelationshipTarget implements ResourceTarget {
  String get relationship;
}
