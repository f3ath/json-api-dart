import 'package:json_api/src/url_design/collection_target.dart';
import 'package:json_api/src/url_design/relationship_target.dart';
import 'package:json_api/src/url_design/resource_target.dart';

abstract class TargetMapper<T> {
  T collection(CollectionTarget target);

  T resource(ResourceTarget target);

  T relationship(RelationshipTarget target);

  T related(RelationshipTarget target);

  T unmatched();
}
