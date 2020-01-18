import 'package:json_api/src/server/request/add_to_relationship.dart';
import 'package:json_api/src/server/request/controller_request.dart';
import 'package:json_api/src/server/request/delete_from_relationship.dart';
import 'package:json_api/src/server/request/fetch_relationship.dart';
import 'package:json_api/src/server/request/invalid_request.dart';
import 'package:json_api/src/server/request/update_relationship.dart';
import 'package:json_api/src/server/target/target.dart';

/// The target of a URI referring a relationship
class RelationshipTarget implements Target {
  /// Resource type
  final String type;

  /// Resource id
  final String id;

  /// Relationship name
  final String relationship;

  const RelationshipTarget(this.type, this.id, this.relationship);

  @override
  ControllerRequest getRequest(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return FetchRelationship(type, id, relationship);
      case 'PATCH':
        return UpdateRelationship(type, id, relationship);
      case 'POST':
        return AddToRelationship(type, id, relationship);
      case 'DELETE':
        return DeleteFromRelationship(type, id, relationship);
      default:
        return InvalidRequest(method);
    }
  }
}
