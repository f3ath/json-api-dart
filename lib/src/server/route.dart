import 'dart:io';

import 'package:json_api/src/server/request.dart';
import 'package:json_api/src/server/uri_builder.dart';

abstract class JsonApiRoute {
  final Uri uri;

  JsonApiRoute(this.uri);

  /// Returns the `self` link uri
  Uri self(UriBuilder schema, {Map<String, String> parameters = const {}});

  JsonApiRequest createRequest(HttpRequest httpRequest);

  /// URI parameters
  Map<String, String> get parameters => uri.queryParameters;
}

class CollectionRoute extends JsonApiRoute {
  final String type;

  CollectionRoute(Uri uri, this.type) : super(uri);

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
  Uri self(UriBuilder schema, {Map<String, String> parameters = const {}}) =>
      schema.collection(type, params: parameters);
}

class RelatedRoute extends JsonApiRoute {
  final String type;
  final String id;
  final String relationship;

  RelatedRoute(Uri uri, this.type, this.id, this.relationship) : super(uri);

  JsonApiRequest createRequest(HttpRequest request) {
    switch (request.method) {
      case 'GET':
        return FetchRelated(request, this);
    }
    throw 'Unexpected method ${request.method}';
  }

  @override
  Uri self(UriBuilder schema, {Map<String, String> parameters = const {}}) =>
      schema.related(type, id, relationship, params: parameters);
}

class RelationshipRoute extends JsonApiRoute {
  final String type;
  final String id;
  final String relationship;

  RelationshipRoute(Uri uri, this.type, this.id, this.relationship)
      : super(uri);

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
  Uri self(UriBuilder builder, {Map<String, String> parameters = const {}}) =>
      builder.relationship(type, id, relationship, params: parameters);

  Uri related(UriBuilder builder, {Map<String, String> params = const {}}) =>
      builder.related(type, id, relationship, params: params);
}

class ResourceRoute extends JsonApiRoute {
  final String type;
  final String id;

  ResourceRoute(Uri uri, this.type, this.id) : super(uri);

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
  Uri self(UriBuilder schema, {Map<String, String> parameters = const {}}) =>
      schema.resource(type, id, params: parameters);
}
