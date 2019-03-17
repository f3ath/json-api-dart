import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/server/page.dart';
import 'package:json_api/src/server/route.dart';

abstract class JsonApiController {
  Future fetchCollection(FetchCollectionRequest rq);

  Future fetchRelated(FetchRelatedRequest rq);

  Future fetchResource(FetchResourceRequest rq);

  Future fetchRelationship(FetchRelationshipRequest rq);

  Future deleteResource(DeleteResourceRequest rq);

  Future createResource(CreateResourceRequest rq);

  Future updateResource(UpdateResourceRequest rq);

  Future replaceRelationship(ReplaceRelationshipRequest rq);

  Future addToRelationship(AddToRelationshipRequest rq);
}

abstract class FetchCollectionRequest {
  CollectionRoute get route;

  Future sendCollection(Iterable<Resource> resources, {Page page});

  Future errorNotFound(Iterable<JsonApiError> errors);
}

abstract class FetchRelatedRequest {
  RelatedRoute get route;

  Future sendCollection(Iterable<Resource> collection);

  Future sendResource(Resource resource);

  Future errorNotFound(Iterable<JsonApiError> errors);
}

abstract class FetchRelationshipRequest {
  RelationshipRoute get route;

  Future sendToMany(Iterable<Identifier> collection);

  Future sendToOne(Identifier id);

  Future errorNotFound(Iterable<JsonApiError> errors);
}

abstract class ReplaceRelationshipRequest {
  RelationshipRoute get route;

  Future<Relationship> getRelationship();

  Future sendNoContent();

  Future sendToMany(Iterable<Identifier> collection);

  Future sendToOne(Identifier id);

  Future errorNotFound(Iterable<JsonApiError> errors);
}

abstract class AddToRelationshipRequest {
  RelationshipRoute get route;

  Future<Iterable<Identifier>> getIdentifiers();

  Future sendToMany(Iterable<Identifier> collection);

  Future errorNotFound(Iterable<JsonApiError> errors);
}

abstract class FetchResourceRequest {
  ResourceRoute get route;

  Future sendResource(Resource resource, {Iterable<Resource> included});

  Future errorNotFound(Iterable<JsonApiError> errors);
}

abstract class DeleteResourceRequest {
  ResourceRoute get route;

  Future sendNoContent();

  Future sendMeta(Map<String, Object> meta);

  Future errorNotFound(Iterable<JsonApiError> errors);
}

abstract class CreateResourceRequest {
  CollectionRoute get route;

  Future<Resource> getResource();

  Future sendCreated(Resource resource);

  Future sendNoContent();

  Future errorConflict(Iterable<JsonApiError> errors);

  Future errorNotFound(Iterable<JsonApiError> errors);
}

abstract class UpdateResourceRequest {
  ResourceRoute get route;

  Future<Resource> getResource();

  Future sendUpdated(Resource resource);

  Future sendNoContent();

  Future errorConflict(Iterable<JsonApiError> errors);

  Future errorForbidden(Iterable<JsonApiError> errors);

  Future errorNotFound(Iterable<JsonApiError> errors);
}
