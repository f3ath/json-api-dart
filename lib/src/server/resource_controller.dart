import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/server/page.dart';
import 'package:json_api/src/server/request.dart';

class Collection<T> {
  Iterable<T> elements;
  final Page page;

  Collection(this.elements, {this.page});
}

/// The [ResourceController] manages resources at application level.
/// It is responsible for CRUD operations over resources.
/// When the operation succeeds, the method should return the value specified in
/// its return type. It may also throw a [ResourceControllerException] which
/// will be converted to an [ErrorObject] and returned to the client in an [ErrorDocument]
abstract class ResourceController {
  /// Returns true if the resource type is supported by the controller
  bool supports(String type);

  Future<OperationResult<Collection<Resource>>> fetchCollection(
      String type, JsonApiHttpRequest request);

  Stream<Resource> fetchResources(Iterable<Identifier> ids);

  Future<Resource> createResource(
      String type, Resource resource, JsonApiHttpRequest request);

  Future<Resource> updateResource(
      String type, String id, Resource resource, JsonApiHttpRequest request);

  /// This method should delete the resource specified by [type] and [id].
  /// It may return metadata to be sent back as 200 OK response.
  /// If an empty map or null is returned, the server will respond with 204 No Content.
  Future<Map<String, Object>> deleteResource(
      String type, String id, JsonApiHttpRequest request);
}

class OperationResult<T> {
  final T result;
  final bool complete;
  final errors = <ErrorObject>[];
  final int httpStatus;

  bool get failed => !complete;

  OperationResult.ok(this.result)
      : complete = true,
        httpStatus = 200;

  OperationResult.fail(this.httpStatus, Iterable<ErrorObject> errors)
      : complete = false,
        result = null {
    this.errors.addAll(errors);
  }
}

class ResourceControllerException implements Exception {
  final int httpStatus;
  final String id;
  final String code;
  final String title;
  final String detail;
  final String sourcePointer;
  final String sourceParameter;

  ResourceControllerException(this.httpStatus,
      {this.id,
      this.code,
      this.sourceParameter,
      this.sourcePointer,
      this.detail,
      this.title}) {
    ArgumentError.checkNotNull(this.httpStatus);
  }
}
