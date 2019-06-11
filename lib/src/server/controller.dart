import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/server/request_target.dart';
import 'package:json_api/src/server/response.dart';

abstract class Controller {
  bool supportsType(String type);

  FutureOr<Response> fetchCollection(
      FetchCollectionRequest request, Map<String, List<String>> query);

  FutureOr<Response> fetchResource(
      FetchResourceRequest request, Map<String, List<String>> query);

  FutureOr<Response> fetchRelated(
      FetchRelatedRequest request, Map<String, List<String>> query);

  FutureOr<Response> fetchRelationship(
      FetchRelationshipRequest request, Map<String, List<String>> query);

  FutureOr<Response> deleteResource(DeleteResourceRequest request);

  FutureOr<Response> createResource(
      CreateResourceRequest request, Resource resource);

  FutureOr<Response> updateResource(
      UpdateResourceRequest request, Resource resource);

  FutureOr<Response> replaceToOne(
      UpdateRelationshipRequest request, Identifier identifier);

  FutureOr<Response> replaceToMany(
      UpdateRelationshipRequest request, List<Identifier> identifiers);

  FutureOr<Response> addToMany(
      AddToManyRequest request, List<Identifier> identifiers);
}

/// Performs double-dispatch on Controller methods
abstract class ControllerDispatcher {
  FutureOr<Response> dispatchCall(
      Controller controller, Map<String, List<String>> query, Object payload);
}

abstract class ControllerRequest {
  RequestTarget get target;
}

abstract class FetchCollectionRequest implements ControllerRequest {
  CollectionTarget get target;
}

abstract class CreateResourceRequest implements ControllerRequest {
  CollectionTarget get target;
}

abstract class FetchResourceRequest implements ControllerRequest {
  ResourceTarget get target;
}

abstract class DeleteResourceRequest implements ControllerRequest {
  ResourceTarget get target;
}

abstract class UpdateResourceRequest implements ControllerRequest {
  ResourceTarget get target;
}

abstract class FetchRelatedRequest implements ControllerRequest {
  RelatedTarget get target;
}

abstract class FetchRelationshipRequest implements ControllerRequest {
  RelationshipTarget get target;
}

abstract class AddToManyRequest implements ControllerRequest {
  RelationshipTarget get target;
}

abstract class UpdateRelationshipRequest implements ControllerRequest {
  RelationshipTarget get target;
}
