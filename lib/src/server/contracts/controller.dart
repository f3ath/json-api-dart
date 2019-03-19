import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/server/collection.dart';
import 'package:json_api/src/server/request_target.dart';

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

  Future<void> errorNotFound(Iterable<JsonApiError> errors);
}

abstract class FetchCollectionRequest extends JsonApiRequest {
  CollectionTarget get target;

  Future<void> sendCollection(Collection<Resource> resources);
}

abstract class CreateResourceRequest extends JsonApiRequest {
  CollectionTarget get target;

  Resource get resource;

  Future<void> sendCreated(Resource resource);

  Future<void> sendNoContent();

  Future<void> errorConflict(Iterable<JsonApiError> errors);
}

abstract class FetchResourceRequest extends JsonApiRequest {
  ResourceTarget get target;

  Future<void> sendResource(Resource resource, {Iterable<Resource> included});
}

abstract class DeleteResourceRequest extends JsonApiRequest {
  ResourceTarget get target;

  Future<void> sendNoContent();

  Future<void> sendMeta(Map<String, Object> meta);
}

abstract class UpdateResourceRequest extends JsonApiRequest {
  ResourceTarget get target;

  Resource get resource;

  Future<void> sendUpdated(Resource resource);

  Future<void> sendNoContent();

  Future<void> errorConflict(Iterable<JsonApiError> errors);

  Future<void> errorForbidden(Iterable<JsonApiError> errors);
}

abstract class FetchRelationshipRequest extends JsonApiRequest {
  RelationshipTarget get target;

  Future<void> sendToMany(Iterable<Identifier> collection);

  Future<void> sendToOne(Identifier id);
}

abstract class ReplaceToOneRequest extends JsonApiRequest {
  RelationshipTarget get target;

  Identifier get identifier;

  Future<void> sendNoContent();

  Future<void> sendToMany(Iterable<Identifier> collection);

  Future<void> sendToOne(Identifier id);
}

abstract class ReplaceToManyRequest extends JsonApiRequest {
  RelationshipTarget get target;

  Iterable<Identifier> get identifiers;

  Future<void> sendNoContent();

  Future<void> sendToMany(Iterable<Identifier> collection);

  Future<void> sendToOne(Identifier id);
}

abstract class AddToManyRequest extends JsonApiRequest {
  RelationshipTarget get target;

  Iterable<Identifier> get identifiers;

  Future<void> sendToMany(Iterable<Identifier> collection);
}

abstract class FetchRelatedRequest extends JsonApiRequest {
  RelatedResourceTarget get target;

  Future<void> sendCollection(Collection<Resource> resources);

  Future<void> sendResource(Resource resource);
}
