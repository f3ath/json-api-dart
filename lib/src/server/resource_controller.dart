import 'dart:async';

import 'package:json_api/src/identifier.dart';
import 'package:json_api/src/resource.dart';
import 'package:json_api/src/server/page.dart';
import 'package:json_api/src/server/request.dart';

class Collection<T> {
  Iterable<T> elements;
  final Page page;

  Collection(this.elements, {this.page});
}

abstract class ResourceController {
  bool supports(String type);

  Future<Collection<Resource>> fetchCollection(
      String type, JsonApiHttpRequest request);

  Stream<Resource> fetchResources(Iterable<Identifier> ids);

  Future<Resource> createResource(
      String type, Resource resource, JsonApiHttpRequest request);

  Future<void> deleteResource(
      String type, String id, JsonApiHttpRequest request);
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
