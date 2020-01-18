import 'dart:async';

import 'package:json_api/src/server/json_api_controller.dart';
import 'package:json_api/src/server/request/controller_request.dart';
import 'package:json_api/src/server/json_api_response.dart';

class FetchCollection implements ControllerRequest {
  final String type;

  FetchCollection(this.type);

  @override
  FutureOr<JsonApiResponse> call<R>(
          JsonApiController<R> controller, Object jsonPayload, R request) =>
      controller.fetchCollection(request, type);
}
