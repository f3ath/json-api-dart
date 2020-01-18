import 'package:json_api/src/server/request/controller_request.dart';
import 'package:json_api/src/server/request/delete_resource.dart';
import 'package:json_api/src/server/request/fetch_resource.dart';
import 'package:json_api/src/server/request/invalid_request.dart';
import 'package:json_api/src/server/request/update_resource.dart';
import 'package:json_api/src/server/target/target.dart';

/// The target of a URI referring to a single resource
class ResourceTarget implements Target {
  /// Resource type
  final String type;

  /// Resource id
  final String id;

  const ResourceTarget(this.type, this.id);

  @override
  ControllerRequest getRequest(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return FetchResource(type, id);
      case 'DELETE':
        return DeleteResource(type, id);
      case 'PATCH':
        return UpdateResource(type, id);
      default:
        return InvalidRequest(method);
    }
  }
}
