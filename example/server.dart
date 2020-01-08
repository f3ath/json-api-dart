import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/http_handler.dart';
import 'package:json_api/url_design.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:uuid/uuid.dart';

/// This example shows how to build a simple CRUD server on top of Dart Shelf
void main() async {
  final host = 'localhost';
  final port = 8080;
  final baseUri = Uri(scheme: 'http', host: host, port: port);
  final jsonApiHandler = createHttpHandler(ShelfRequestResponseConverter(),
      CRUDController(), PathBasedUrlDesign(baseUri));

  await serve(jsonApiHandler, host, port);
  print('Serving at $baseUri');
}

class ShelfRequestResponseConverter
    implements HttpMessageConverter<Request, Response> {
  @override
  FutureOr<Response> createResponse(
          int statusCode, String body, Map<String, String> headers) =>
      Response(statusCode, body: body, headers: headers);

  @override
  FutureOr<String> getBody(Request request) => request.readAsString();

  @override
  FutureOr<String> getMethod(Request request) => request.method;

  @override
  FutureOr<Uri> getUri(Request request) => request.requestedUri;
}

class CRUDController implements JsonApiController<Request> {
  final store = <String, Map<String, Resource>>{};

  @override
  FutureOr<ControllerResponse> createResource(
      Request request, String type, Resource resource) {
    if (resource.type != type) {
      return ErrorResponse.conflict(
          [JsonApiError(detail: 'Incompatible type')]);
    }
    final repo = _repo(type);
    if (resource.id != null) {
      if (repo.containsKey(resource.id)) {
        return ErrorResponse.conflict(
            [JsonApiError(detail: 'Resource already exists')]);
      }
      repo[resource.id] = resource;
      return NoContentResponse();
    }
    final id = Uuid().v4();
    repo[id] = resource.withId(id);
    return ResourceCreatedResponse(repo[id]);
  }

  @override
  FutureOr<ControllerResponse> fetchResource(
      Request request, String type, String id) {
    final repo = _repo(type);
    if (repo.containsKey(id)) {
      return ResourceResponse(repo[id]);
    }
    return ErrorResponse.notFound(
        [JsonApiError(detail: 'Resource not found', status: '404')]);
  }

  @override
  FutureOr<ControllerResponse> addToRelationship(
      Request request, String type, String id, String relationship) {
    // TODO: implement addToRelationship
    return null;
  }

  @override
  FutureOr<ControllerResponse> deleteFromRelationship(
      Request request, String type, String id, String relationship) {
    // TODO: implement deleteFromRelationship
    return null;
  }

  @override
  FutureOr<ControllerResponse> deleteResource(
      Request request, String type, String id) {
    final repo = _repo(type);
    if (!repo.containsKey(id)) {
      return ErrorResponse.notFound(
          [JsonApiError(detail: 'Resource not found')]);
    }
    final resource = repo[id];
    repo.remove(id);
    final relationships = {...resource.toOne, ...resource.toMany};
    if (relationships.isNotEmpty) {
      return MetaResponse({'relationships': relationships.length});
    }
    return NoContentResponse();
  }

  @override
  FutureOr<ControllerResponse> fetchCollection(Request request, String type) {
    final repo = _repo(type);
    return CollectionResponse(repo.values);
  }

  @override
  FutureOr<ControllerResponse> fetchRelated(
      Request request, String type, String id, String relationship) {
    final resource = _repo(type)[id];
    if (resource == null) {
      return ErrorResponse.notFound(
          [JsonApiError(detail: 'Resource not found')]);
    }
    if (resource.toOne.containsKey(relationship)) {
      final related = resource.toOne[relationship];
      if (related == null) {
        return RelatedResourceResponse(null);
      }
      return RelatedResourceResponse(_repo(related.type)[related.id]);
    }
    if (resource.toMany.containsKey(relationship)) {
      final related = resource.toMany[relationship];
      return RelatedCollectionResponse(related.map((r) => _repo(r.type)[r.id]));
    }
    return ErrorResponse.notFound(
        [JsonApiError(detail: 'Relatioship not found')]);
  }

  @override
  FutureOr<ControllerResponse> fetchRelationship(
      Request request, String type, String id, String relationship) {
    // TODO: implement fetchRelationship
    return null;
  }

  @override
  FutureOr<ControllerResponse> updateResource(
      Request request, String type, String id) {
    // TODO: implement updateResource
    return null;
  }

  @override
  FutureOr<ControllerResponse> updateToMany(
      Request request, String type, String id, String relationship) {
    // TODO: implement updateToMany
    return null;
  }

  @override
  FutureOr<ControllerResponse> updateToOne(
      Request request, String type, String id, String relationship) {
    // TODO: implement updateToOne
    return null;
  }

  Map<String, Resource> _repo(String type) {
    store.putIfAbsent(type, () => {});
    return store[type];
  }
}
