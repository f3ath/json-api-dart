import 'dart:io';

import 'package:json_api/src/server/request.dart';
import 'package:json_api/src/server/uri_builder.dart';

abstract class JsonApiRoute {
  /// Returns the `self` link uri
  Uri self(UriBuilder schema, {Map<String, String> params = const {}});

  JsonApiRequest createRequest(HttpRequest httpRequest);
}

class CollectionRoute implements JsonApiRoute {
  final String type;

  CollectionRoute(this.type);

  JsonApiRequest createRequest(HttpRequest request) {
    switch (request.method) {
      case 'GET':
        return FetchCollection(request, this);
      case 'POST':
        return CreateResource(request, this);
    }
    throw 'Unexpected method ${request.method}';
  }

  @override
  Uri self(UriBuilder schema, {Map<String, String> params = const {}}) =>
      schema.collection(type, params: params);
}

class RelatedRoute implements JsonApiRoute {
  final String type;
  final String id;
  final String relationship;

  RelatedRoute(this.type, this.id, this.relationship);

  JsonApiRequest createRequest(HttpRequest request) {
    switch (request.method) {
      case 'GET':
        return FetchRelated(request, this);
    }
    throw 'Unexpected method ${request.method}';
  }

  @override
  Uri self(UriBuilder schema, {Map<String, String> params = const {}}) =>
      schema.related(type, id, relationship, params: params);
}

class RelationshipRoute implements JsonApiRoute {
  final String type;
  final String id;
  final String relationship;

  RelationshipRoute(this.type, this.id, this.relationship);

  JsonApiRequest createRequest(HttpRequest request) {
    switch (request.method) {
      case 'GET':
        return FetchRelationship(request, this);
      case 'PATCH':
        return ReplaceRelationship(request, this);
      case 'POST':
        return AddToRelationship(request, this);
    }
    throw 'Unexpected method ${request.method}';
  }

  @override
  Uri self(UriBuilder builder, {Map<String, String> params = const {}}) =>
      builder.relationship(type, id, relationship, params: params);

  Uri related(UriBuilder builder, {Map<String, String> params = const {}}) =>
      builder.related(type, id, relationship, params: params);
}

class ResourceRoute implements JsonApiRoute {
  final String type;
  final String id;

  ResourceRoute(this.type, this.id);

  JsonApiRequest createRequest(HttpRequest request) {
    switch (request.method) {
      case 'GET':
        return FetchResource(request, this);
      case 'DELETE':
        return DeleteResource(request, this);
      case 'PATCH':
        return UpdateResource(request, this);
    }
    throw 'Unexpected method ${request.method}';
  }

  @override
  Uri self(UriBuilder schema, {Map<String, String> params = const {}}) =>
      schema.resource(type, id, params: params);
}
