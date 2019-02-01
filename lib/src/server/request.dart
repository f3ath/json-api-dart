import 'package:json_api/src/server/response.dart';

abstract class JsonApiController<R> {
  Future<ServerResponse> fetchCollection(CollectionRequest<R> request);

  Future<ServerResponse> fetchResource(ResourceRequest<R> request);
}

abstract class JsonApiRequest<R> {
  String get type;

  R get httpRequest;

  Future<ServerResponse> perform(JsonApiController<R> controller);
}

class CollectionRequest<R> implements JsonApiRequest<R> {
  final String type;
  final R httpRequest;

  CollectionRequest(this.type, {this.httpRequest});

  @override
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
