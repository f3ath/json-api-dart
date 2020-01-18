import 'dart:async';

import 'package:json_api/src/server/json_api_controller.dart';
import 'package:json_api/src/server/request/controller_request.dart';
import 'package:json_api/src/server/json_api_response.dart';

class FetchRelated implements ControllerRequest {
  final String type;
  final String id;
  final String relationship;

  FetchRelated(this.type, this.id, this.relationship);

  @override
  FutureOr<JsonApiResponse> call<R>(
          JsonApiController<R> controller, Object jsonPayload, R request) =>
      controller.fetchRelated(request, type, id, relationship);
}
