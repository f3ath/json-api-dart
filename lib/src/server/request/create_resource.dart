import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/server/json_api_controller.dart';
import 'package:json_api/src/server/request/controller_request.dart';
import 'package:json_api/src/server/json_api_response.dart';

class CreateResource implements ControllerRequest {
  final String type;

  CreateResource(this.type);

  @override
  FutureOr<JsonApiResponse> call<R>(
          JsonApiController<R> controller, Object jsonPayload, R request) =>
      controller.createResource(
          request, type, ResourceData.fromJson(jsonPayload).unwrap());
}
