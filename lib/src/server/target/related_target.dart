import 'package:json_api/src/server/request/controller_request.dart';
import 'package:json_api/src/server/request/fetch_related.dart';
import 'package:json_api/src/server/request/invalid_request.dart';
import 'package:json_api/src/server/target/target.dart';

/// The target of a URI referring a related resource or collection
class RelatedTarget implements Target {
  /// Resource type
  final String type;

  /// Resource id
  final String id;

  /// Relationship name
  final String relationship;

  const RelatedTarget(this.type, this.id, this.relationship);

  @override
  ControllerRequest getRequest(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return FetchRelated(type, id, relationship);
      default:
        return InvalidRequest(method);
    }
  }
}
