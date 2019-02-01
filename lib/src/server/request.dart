import 'package:json_api/src/server/response.dart';

abstract class JsonApiController<R> {
  Future<ServerResponse> fetchCollection(CollectionRequest<R> request);

  Future<ServerResponse> fetchResource(ResourceRequest<R> request);

  Future<ServerResponse> fetchRelated(RelatedRequest<R> relatedRequest);

  Future<ServerResponse> fetchRelationship(RelationshipRequest request);
}

abstract class JsonApiRequest<R> {
  String get type;

  R get httpRequest;

  Future<ServerResponse> perform(JsonApiController<R> controller);
}

class CollectionRequest<R> implements JsonApiRequest<R> {
  final String type;
  final Map<String, String> queryParameters;
  final R httpRequest;

  CollectionRequest(this.type, {this.httpRequest, this.queryParameters});

  Future<ServerResponse> perform(JsonApiController<R> controller) =>
      controller.fetchCollection(this);
}

class ResourceRequest<R> implements JsonApiRequest<R> {
  final String type;
  final String id;
  final R httpRequest;

  ResourceRequest(this.type, this.id, {this.httpRequest});

  @override
  Future<ServerResponse> perform(JsonApiController<R> controller) =>
      controller.fetchResource(this);
}

class RelatedRequest<R> implements JsonApiRequest<R> {
  final String type;
  final String id;
  final String name;
  final R httpRequest;

  RelatedRequest(this.type, this.id, this.name, {this.httpRequest});

  Future<ServerResponse> perform(JsonApiController<R> controller) =>
      controller.fetchRelated(this);
}

class RelationshipRequest<R> implements JsonApiRequest<R> {
  final String type;
  final String id;
  final String name;
  final R httpRequest;

  RelationshipRequest(this.type, this.id, this.name, {this.httpRequest});

  Future<ServerResponse> perform(JsonApiController<R> controller) =>
      controller.fetchRelationship(this);
}
