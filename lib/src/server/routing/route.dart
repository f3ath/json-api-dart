import 'dart:async';

import 'package:json_api/query.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/http_method.dart';
import 'package:json_api/src/server/response/response.dart';

abstract class Route {
  FutureOr<Response> call(
      Controller controller, Query query, HttpMethod method, Object body);
}
