import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/server/json_api_controller.dart';
import 'package:json_api/src/server/request/controller_request.dart';
import 'package:json_api/src/server/json_api_response.dart';

class UpdateResource implements ControllerRequest {
  final String type;
  final String id;

  UpdateResource(this.type, this.id);

  @override
  FutureOr<JsonApiResponse> call<R>(
          JsonApiController<R> controller, Object jsonPayload, R request) =>
      controller.updateResource(
          request, type, id, ResourceData.fromJson(jsonPayload).unwrap());
}
