import 'package:json_api/document.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/controller_response.dart';
import 'package:json_api/src/server/request.dart';

abstract class ResolvableRequest {
  Future<ControllerResponse> resolveBy(Controller controller);
}

class FetchCollection implements ResolvableRequest {
  FetchCollection(this.request);

  final CollectionRequest request;

  @override
  Future<ControllerResponse> resolveBy(Controller controller) =>
      controller.fetchCollection(request);
}

class CreateResource implements ResolvableRequest {
  CreateResource(this.request);

  final CollectionRequest request;

  @override
  Future<ControllerResponse> resolveBy(Controller controller) =>
      controller.createResource(
          request, ResourceData.fromJson(request.decodePayload()).unwrap());
}

class FetchResource implements ResolvableRequest {
  FetchResource(this.request);

  final ResourceRequest request;

  @override
  Future<ControllerResponse> resolveBy(Controller controller) =>
      controller.fetchResource(request);
}

class DeleteResource implements ResolvableRequest {
  DeleteResource(this.request);

  final ResourceRequest request;

  @override
  Future<ControllerResponse> resolveBy(Controller controller) =>
      controller.deleteResource(request);
}

class UpdateResource implements ResolvableRequest {
  UpdateResource(this.request);

  final ResourceRequest request;

  @override
  Future<ControllerResponse> resolveBy(Controller controller) =>
      controller.updateResource(
          request, ResourceData.fromJson(request.decodePayload()).unwrap());
}

class FetchRelated implements ResolvableRequest {
  FetchRelated(this.request);

  final RelatedRequest request;

  @override
  Future<ControllerResponse> resolveBy(Controller controller) =>
      controller.fetchRelated(request);
}

class FetchRelationship implements ResolvableRequest {
  FetchRelationship(this.request);

  final RelationshipRequest request;

  @override
  Future<ControllerResponse> resolveBy(Controller controller) =>
      controller.fetchRelationship(request);
}

class DeleteFromRelationship implements ResolvableRequest {
  DeleteFromRelationship(this.request);

  final RelationshipRequest request;

  @override
  Future<ControllerResponse> resolveBy(Controller controller) =>
      controller.deleteFromRelationship(
          request, ToMany.fromJson(request.decodePayload()).unwrap());
}

class AddToRelationship implements ResolvableRequest {
  AddToRelationship(this.request);

  final RelationshipRequest request;

  @override
  Future<ControllerResponse> resolveBy(Controller controller) =>
      controller.addToRelationship(
          request, ToMany.fromJson(request.decodePayload()).unwrap());
}

class ReplaceRelationship implements ResolvableRequest {
  ReplaceRelationship(this.request);

  final RelationshipRequest request;

  @override
  Future<ControllerResponse> resolveBy(Controller controller) async {
    final r = Relationship.fromJson(request.decodePayload());
    if (r is ToOne) {
      return controller.replaceToOne(request, r.unwrap());
    }
    if (r is ToMany) {
      return controller.replaceToMany(request, r.unwrap());
    }
    throw IncompleteRelationshipException();
  }
}

/// Thrown if the relationship object has no data
class IncompleteRelationshipException implements Exception {}
