import 'dart:async';

import 'package:json_api/src/server/json_api_controller.dart';
import 'package:json_api/src/server/request/controller_request.dart';
import 'package:json_api/src/server/json_api_response.dart';

class InvalidRequest implements ControllerRequest {
  final String method;

  InvalidRequest(this.method);

  @override
  FutureOr<JsonApiResponse> call<R>(
      JsonApiController<R> controller, Object jsonPayload, R request) {
    // TODO: implement call
    return null;
  }
}
