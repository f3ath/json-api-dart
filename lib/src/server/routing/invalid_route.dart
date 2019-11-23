import 'package:json_api/query.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/http_method.dart';
import 'package:json_api/src/server/response/response.dart';
import 'package:json_api/src/server/routing/route.dart';

class InvalidRoute implements Route {
  InvalidRoute();

  @override
  Future<Response> call(
          Controller controller, Query query, HttpMethod method, Object body) =>
      null;
}
