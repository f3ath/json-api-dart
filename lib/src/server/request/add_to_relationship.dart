import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/server/json_api_controller.dart';
import 'package:json_api/src/server/request/controller_request.dart';
import 'package:json_api/src/server/json_api_response.dart';

class AddToRelationship implements ControllerRequest {
  final String type;
  final String id;
  final String relationship;

  AddToRelationship(this.type, this.id, this.relationship);

  @override
  FutureOr<JsonApiResponse> call<R>(
          JsonApiController<R> controller, Object jsonPayload, R request) =>
      controller.addToRelationship(request, type, id, relationship,
          ToMany.fromJson(jsonPayload).unwrap());
}
