import 'package:json_api/src/url_design/resource_target.dart';

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
