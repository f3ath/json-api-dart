import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/server/json_api_controller.dart';
import 'package:json_api/src/server/request/controller_request.dart';
import 'package:json_api/src/server/json_api_response.dart';

class UpdateRelationship implements ControllerRequest {
  final String type;
  final String id;
  final String relationship;

  UpdateRelationship(this.type, this.id, this.relationship);

  @override
  FutureOr<JsonApiResponse> call<R>(
      JsonApiController<R> controller, Object jsonPayload, R request) {
    final r = Relationship.fromJson(jsonPayload);
    if (r is ToOne) {
      return controller.replaceToOne(
          request, type, id, relationship, r.unwrap());
    }
    if (r is ToMany) {
      return controller.replaceToMany(
          request, type, id, relationship, r.unwrap());
    }
  }
}
