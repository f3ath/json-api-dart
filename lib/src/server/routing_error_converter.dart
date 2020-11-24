import 'package:json_api/handler.dart';
import 'package:json_api/src/server/json_api_response.dart';
import 'package:json_api/src/server/method_not_allowed.dart';
import 'package:json_api/src/server/unmatched_target.dart';

class RoutingErrorConverter implements Handler<Object, JsonApiResponse /*?*/ > {
  const RoutingErrorConverter();

  @override
  Future<JsonApiResponse /*?*/ > call(Object error) async {
    if (error is MethodNotAllowed) {
      return JsonApiResponse.methodNotAllowed();
    }
    if (error is UnmatchedTarget) {
      return JsonApiResponse.badRequest();
    }
    return null;
  }
}
