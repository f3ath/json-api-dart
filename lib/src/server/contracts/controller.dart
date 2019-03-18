import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/server/contracts/page.dart';

abstract class JsonApiController {
  Future<void> fetchCollection(FetchCollectionRequest rq);

  Future<void> fetchRelated(FetchRelatedRequest rq);

  Future<void> fetchResource(FetchResourceRequest rq);

  Future<void> fetchRelationship(FetchRelationshipRequest rq);

  Future<void> deleteResource(DeleteResourceRequest rq);

  Future<void> createResource(CreateResourceRequest rq);

  Future<void> updateResource(UpdateResourceRequest rq);

  Future<void> replaceToOne(ReplaceToOneRequest rq);

  Future<void> replaceToMany(ReplaceToManyRequest rq);

  Future<void> addToMany(AddToManyRequest rq);
}

abstract class JsonApiRequest {
  Uri get uri;

  String get type;

  Future<void> errorNotFound(Iterable<JsonApiError> errors);
}

abstract class FetchCollectionRequest extends JsonApiRequest {
  Future<void> sendCollection(Iterable<Resource> resources, {Page page});
}

abstract class FetchRelatedRequest extends JsonApiRequest {
  String get id;

  String get relationship;

  Future<void> sendCollection(Iterable<Resource> collection);

  Future<void> sendResource(Resource resource);
}

abstract class FetchRelationshipRequest extends JsonApiRequest {
  String get id;

  String get relationship;

  Future<void> sendToMany(Iterable<Identifier> collection);

  Future<void> sendToOne(Identifier id);
}

abstract class ReplaceToOneRequest extends JsonApiRequest {
  String get id;

  String get relationship;

  Identifier get identifier;

  Future<void> sendNoContent();

  Future<void> sendToMany(Iterable<Identifier> collection);

  Future<void> sendToOne(Identifier id);
}

abstract class ReplaceToManyRequest extends JsonApiRequest {
  String get id;

  String get relationship;

  Iterable<Identifier> get identifiers;

  Future<void> sendNoContent();

  Future<void> sendToMany(Iterable<Identifier> collection);

  Future<void> sendToOne(Identifier id);
}

abstract class AddToManyRequest extends JsonApiRequest {
  String get id;

  String get relationship;

  Iterable<Identifier> get identifiers;

  Future<void> sendToMany(Iterable<Identifier> collection);
}

abstract class FetchResourceRequest extends JsonApiRequest {
  String get id;

  Future<void> sendResource(Resource resource, {Iterable<Resource> included});
}

abstract class DeleteResourceRequest extends JsonApiRequest {
  String get id;

  Future<void> sendNoContent();

  Future<void> sendMeta(Map<String, Object> meta);
}

abstract class CreateResourceRequest extends JsonApiRequest {
  Resource get resource;

  Future<void> sendCreated(Resource resource);

  Future<void> sendNoContent();

  Future<void> errorConflict(Iterable<JsonApiError> errors);
}

abstract class UpdateResourceRequest extends JsonApiRequest {
  String get id;

  Resource get resource;

  Future<void> sendUpdated(Resource resource);

  Future<void> sendNoContent();

  Future<void> errorConflict(Iterable<JsonApiError> errors);

  Future<void> errorForbidden(Iterable<JsonApiError> errors);
}
