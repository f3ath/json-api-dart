import 'dart:convert';

import 'package:json_api/document.dart';

class ServerResponse {
  final String body;
  final int status;

  ServerResponse(this.status, {this.body});
}

class ServerRequest {
  final String body;
  final Uri uri;

  ServerRequest(this.uri, {this.body});
}

class JsonApiServer {
  final ResourceController resourceController;
  JsonApiServer(this.resourceController);

  Future<ServerResponse> handle(ServerRequest rq) async {
    final seg = rq.uri.pathSegments.first;
    if (seg == 'unicorns') {
      return ServerResponse(404);
    }
    final collection = await resourceController.fetchCollection('brands');
    final doc = CollectionDocument(collection.elements);
    return ServerResponse(200, body: json.encode(doc));
  }
}

class Collection<T> {
  Iterable<T> elements;

  Collection(this.elements);
}

abstract class ResourceController {
  Future<Collection<Resource>> fetchCollection(String type);
}

