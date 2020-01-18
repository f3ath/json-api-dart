import 'package:json_api/src/server/request/controller_request.dart';
import 'package:json_api/src/server/request/create_resource.dart';
import 'package:json_api/src/server/request/fetch_collection.dart';
import 'package:json_api/src/server/request/invalid_request.dart';
import 'package:json_api/src/server/target/target.dart';

/// The target of a URI referring a resource collection
class CollectionTarget implements Target {
  /// Resource type
  final String type;

  const CollectionTarget(this.type);

  @override
  ControllerRequest getRequest(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return FetchCollection(type);
      case 'POST':
        return CreateResource(type);
      default:
        return InvalidRequest(method);
    }
  }
}
