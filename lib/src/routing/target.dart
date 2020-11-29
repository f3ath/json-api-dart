import 'package:json_api/core.dart';

/// A request target
abstract class Target {
  T map<T>(TargetMapper<T> mapper);
}

abstract class TargetMapper<T> {
  T collection(CollectionTarget target);

  T resource(ResourceTarget target);

  T related(RelatedTarget target);

  T relationship(RelationshipTarget target);
}

class CollectionTarget implements Target {
  const CollectionTarget(this.type);

  final String type;

  @override
  T map<T>(TargetMapper<T> mapper) => mapper.collection(this);
}

class ResourceTarget implements Target {
  const ResourceTarget(this.ref);

  final Ref ref;

  @override
  T map<T>(TargetMapper<T> mapper) => mapper.resource(this);
}

class RelatedTarget implements Target {
  const RelatedTarget(this.ref, this.relationship);

  final Ref ref;

  final String relationship;

  @override
  T map<T>(TargetMapper<T> mapper) => mapper.related(this);
}

class RelationshipTarget implements Target {
  const RelationshipTarget(this.ref, this.relationship);

  final Ref ref;

  final String relationship;

  @override
  T map<T>(TargetMapper<T> mapper) => mapper.relationship(this);
}
