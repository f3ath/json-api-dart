import 'package:json_api/src/server/request/controller_request.dart';
import 'package:json_api/src/server/request/invalid_request.dart';
import 'package:json_api/src/server/target/target.dart';

/// Request URI target which is not recognized by the URL Design.
class InvalidTarget implements Target {
  final Uri uri;

  @override
  const InvalidTarget(this.uri);

  @override
  ControllerRequest getRequest(String method) => InvalidRequest(method);
}
