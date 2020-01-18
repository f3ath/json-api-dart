import 'dart:async';

import 'package:json_api/src/server/json_api_controller.dart';
import 'package:json_api/src/server/json_api_response.dart';

abstract class ControllerRequest {
  /// Calls the appropriate method of [controller]
  FutureOr<JsonApiResponse> call<R>(
      JsonApiController<R> controller, Object jsonPayload, R request);
}
