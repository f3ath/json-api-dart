import 'package:json_api/http.dart';
import 'package:json_api/src/server/_internal/method_not_allowed.dart';
import 'package:json_api/src/server/_internal/unmatched_target.dart';
import 'package:json_api/src/server/error_converter.dart';
import 'package:json_api/src/server/response.dart';

class RoutingErrorHandler implements ErrorConverter {
  const RoutingErrorHandler();

  @override
  Future<HttpResponse /*?*/ > convert(Object error) async {
    if (error is MethodNotAllowed) {
      return Response.methodNotAllowed();
    }
    if (error is UnmatchedTarget) {
      return Response.badRequest();
    }
    return null;
  }
}
