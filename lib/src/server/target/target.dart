import 'package:json_api/routing.dart';
import 'package:json_api/src/server/request/controller_request.dart';
import 'package:json_api/src/server/target/collection_target.dart';
import 'package:json_api/src/server/target/invalid_target.dart';

/// The target of a JSON:API request URI. The URI target and the request method
/// uniquely identify the meaning of the JSON:API request.
abstract class Target {
  /// Returns the request corresponding to the request [method].
  ControllerRequest getRequest(String method);

  static Target match(Uri uri, Routing routing) {
    Target target = InvalidTarget(uri);
    final collection = routing.collection.match(uri);
    if( collection != null) {
      return CollectionTarget(collection.type);
    }
    if (routing.collection
        .match(uri, (type) => target = CollectionTarget(type))) {
      return target;
    }
  }
}
