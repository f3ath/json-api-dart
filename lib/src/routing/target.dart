sealed class Target() {
  String get type;
}

class const CollectionTarget(@override final String type) implements Target;

class const ResourceTarget(@override final String type, final String id) implements Target;

class const RelatedTarget(@override final String type, final String id, final String relationship)
    implements Target;

class const RelationshipTarget(
  @override final String type,
  final String id,
  final String relationship,
) implements Target;
