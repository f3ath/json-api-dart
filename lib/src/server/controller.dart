import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/server/request/target.dart';
import 'package:json_api/src/server/response.dart';

abstract class Controller {
  FutureOr<Response> fetchCollection(
      CollectionTarget target, Map<String, List<String>> query);

  FutureOr<Response> fetchResource(
      ResourceTarget target, Map<String, List<String>> query);

  FutureOr<Response> fetchRelated(
      RelatedTarget target, Map<String, List<String>> query);

  FutureOr<Response> fetchRelationship(
      RelationshipTarget target, Map<String, List<String>> query);

  FutureOr<Response> deleteResource(ResourceTarget target);

  FutureOr<Response> createResource(CollectionTarget target, Resource resource);

  FutureOr<Response> updateResource(ResourceTarget target, Resource resource);

  FutureOr<Response> replaceToOne(
      RelationshipTarget target, Identifier identifier);

  FutureOr<Response> replaceToMany(
      RelationshipTarget target, List<Identifier> identifiers);

  FutureOr<Response> addToMany(
      RelationshipTarget target, List<Identifier> identifiers);
}

/// Performs double-dispatch on Controller methods
abstract class Request {
  FutureOr<Response> call(
      Controller controller, Map<String, List<String>> query, Object payload);
}
