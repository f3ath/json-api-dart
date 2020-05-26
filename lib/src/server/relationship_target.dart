import 'package:json_api/src/server/resource_target.dart';

class RelationshipTarget {
  const RelationshipTarget(this.type, this.id, this.relationship);

  final String type;
  final String id;
  final String relationship;

  ResourceTarget get resource => ResourceTarget(type, id);
}
