class const Target(final String type);

class const ResourceTarget(@override final String type, final String id)
    implements Target;

class const RelatedTarget(
  @override final String type,
  @override final String id,
  final String relationship,
) implements ResourceTarget;

class const RelationshipTarget(
  @override final String type,
  @override final String id,
  final String relationship,
) implements ResourceTarget;
