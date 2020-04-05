import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/controller_request.dart';
import 'package:json_api/src/server/controller_response.dart';

abstract class Resolvable {
  Future<ControllerResponse> resolve(Controller controller);
}

class FetchCollection implements Resolvable {
  FetchCollection(this.request);

  final CollectionRequest request;

  @override
  Future<ControllerResponse> resolve(Controller controller) =>
      controller.fetchCollection(request);
}

class CreateResource implements Resolvable {
  CreateResource(this.request);

  final CollectionRequest request;

  @override
  Future<ControllerResponse> resolve(Controller controller) =>
      controller.createResource(request,
          ResourceData.fromJson(jsonDecode(request.request.body)).unwrap());
}

class FetchResource implements Resolvable {
  FetchResource(this.request);

  final ResourceRequest request;

  @override
  Future<ControllerResponse> resolve(Controller controller) =>
      controller.fetchResource(request);
}

class DeleteResource implements Resolvable {
  DeleteResource(this.request);

  final ResourceRequest request;

  @override
  Future<ControllerResponse> resolve(Controller controller) =>
      controller.deleteResource(request);
}

class UpdateResource implements Resolvable {
  UpdateResource(this.request);

  final ResourceRequest request;

  @override
  Future<ControllerResponse> resolve(Controller controller) =>
      controller.updateResource(request,
          ResourceData.fromJson(jsonDecode(request.request.body)).unwrap());
}

class FetchRelated implements Resolvable {
  FetchRelated(this.request);

  final RelatedRequest request;

  @override
  Future<ControllerResponse> resolve(Controller controller) =>
      controller.fetchRelated(request);
}

class FetchRelationship implements Resolvable {
  FetchRelationship(this.request);

  final RelationshipRequest request;

  @override
  Future<ControllerResponse> resolve(Controller controller) =>
      controller.fetchRelationship(request);
}

class DeleteFromRelationship implements Resolvable {
  DeleteFromRelationship(this.request);

  final RelationshipRequest request;

  @override
  Future<ControllerResponse> resolve(Controller controller) =>
      controller.deleteFromRelationship(
          request, ToMany.fromJson(jsonDecode(request.request.body)).unwrap());
}

class AddToRelationship implements Resolvable {
  AddToRelationship(this.request);

  final RelationshipRequest request;

  @override
  Future<ControllerResponse> resolve(Controller controller) =>
      controller.addToRelationship(
          request, ToMany.fromJson(jsonDecode(request.request.body)).unwrap());
}

class ReplaceRelationship implements Resolvable {
  ReplaceRelationship(this.request);

  final RelationshipRequest request;

  @override
  Future<ControllerResponse> resolve(Controller controller) async {
    final r = Relationship.fromJson(jsonDecode(request.request.body));
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
