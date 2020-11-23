import 'package:json_api/src/routing/reference.dart';

/// A request target
abstract class Target {
  /// Targeted resource type
  String get type;

  T map<T>(TargetMapper<T> mapper);
}

abstract class TargetMapper<T> {
  T collection(CollectionTarget target);

  T resource(ResourceTarget target);

  T related(RelatedTarget target);

  T relationship(RelationshipTarget target);
}

class CollectionTarget extends CollectionReference implements Target {
  const CollectionTarget(String type) : super(type);

  @override
  T map<T>(TargetMapper<T> mapper) => mapper.collection(this);
}

class ResourceTarget extends ResourceReference implements Target {
  const ResourceTarget(String type, String id) : super(type, id);

  @override
  T map<T>(TargetMapper<T> mapper) => mapper.resource(this);
}

class RelatedTarget extends RelationshipReference implements Target {
  const RelatedTarget(String type, String id, String relationship)
      : super(type, id, relationship);

  @override
  T map<T>(TargetMapper<T> mapper) => mapper.related(this);
}

class RelationshipTarget extends RelationshipReference implements Target {
  const RelationshipTarget(String type, String id, String relationship)
      : super(type, id, relationship);

  @override
  T map<T>(TargetMapper<T> mapper) => mapper.relationship(this);
}
