import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:json_api/document.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/server/page.dart';

abstract class UrlBuilder {
  /// Builds a URI for a resource collection
  Uri collection(String type, {Map<String, String> params = const {}});

  /// Builds a URI for a single resource
  Uri resource(String type, String id, {Map<String, String> params = const {}});

  /// Builds a URI for a related resource
  Uri related(String type, String id, String relationship,
      {Map<String, String> params = const {}});

  /// Builds a URI for a relationship object
  Uri relationship(String type, String id, String relationship,
      {Map<String, String> params = const {}});
}

abstract class RouteResolver {
  /// Resolves HTTP request to [JsonAiRequest] object
  JsonApiRoute getRoute(Uri uri);
}

/// Routing defines the design of URLs.
abstract class Routing implements UrlBuilder, RouteResolver {}

/// StandardRouting implements the recommended URL design schema:
///
/// /photos - for a collection
/// /photos/1 - for a resource
/// /photos/1/relationships/author - for a relationship
/// /photos/1/author - for a related resource
///
/// See https://jsonapi.org/recommendations/#urls
class StandardRouting implements Routing {
  final Uri base;

  StandardRouting(this.base) {
    ArgumentError.checkNotNull(base, 'base');
  }

  collection(String type, {Map<String, String> params = const {}}) {
    final combined = <String, String>{}
      ..addAll(base.queryParameters)
      ..addAll(params);
    return base.replace(
        pathSegments: base.pathSegments + [type],
        queryParameters: combined.isNotEmpty ? combined : null);
  }

  related(String type, String id, String relationship,
          {Map<String, String> params = const {}}) =>
      base.replace(pathSegments: base.pathSegments + [type, id, relationship]);

  relationship(String type, String id, String relationship,
          {Map<String, String> params = const {}}) =>
      base.replace(
          pathSegments:
              base.pathSegments + [type, id, 'relationships', relationship]);

  resource(String type, String id, {Map<String, String> params = const {}}) =>
      base.replace(pathSegments: base.pathSegments + [type, id]);

  JsonApiRoute getRoute(Uri uri) {
    final segments = uri.pathSegments;
    switch (segments.length) {
      case 1:
        return CollectionRoute(segments[0]);
      case 2:
        return ResourceRoute(segments[0], segments[1]);
      case 3:
        return RelatedRoute(segments[0], segments[1], segments[2]);
      case 4:
        if (segments[2] == 'relationships') {
          return RelationshipRoute(segments[0], segments[1], segments[3]);
        }
    }
    return null; // TODO: replace with a null-object
  }
}

abstract class JsonApiRoute {
  Uri print(UrlBuilder schema, {Map<String, String> params = const {}});

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
  Uri print(UrlBuilder schema, {Map<String, String> params = const {}}) =>
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
  Uri print(UrlBuilder schema, {Map<String, String> params = const {}}) =>
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
  Uri print(UrlBuilder schema, {Map<String, String> params = const {}}) =>
      schema.relationship(type, id, relationship, params: params);
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
  Uri print(UrlBuilder schema, {Map<String, String> params = const {}}) =>
      schema.collection(type, params: params);
}

abstract class JsonApiRequest {
  final HttpRequest _request;
  JsonApiServer _server;

  JsonApiRequest(this._request);

  Map<String, String> get queryParameters =>
      _request.requestedUri.queryParameters;

  HttpResponse get _response => _request.response;

  Future call(JsonApiController controller);

  Future notFound([List<ErrorObject> errors = const []]) =>
      _server.error(_response, 404, errors);

  bind(JsonApiServer server) => _server = server;
}

class FetchCollection extends JsonApiRequest {
  final CollectionRoute route;

  FetchCollection(HttpRequest request, this.route) : super(request);

  Future call(JsonApiController controller) => controller.fetchCollection(this);

  Future collection(Collection<Resource> collection) =>
      _server.collection(_response, route, collection);
}

class FetchRelated extends JsonApiRequest {
  final RelatedRoute route;

  FetchRelated(HttpRequest request, this.route) : super(request);

  Future call(JsonApiController controller) => controller.fetchRelated(this);

  Future collection(Collection<Resource> collection) =>
      _server.relatedCollection(_response, route, collection);

  Future resource(Resource resource) =>
      _server.relatedResource(_response, route, resource);
}

class FetchRelationship extends JsonApiRequest {
  final RelationshipRoute route;

  FetchRelationship(HttpRequest request, this.route) : super(request);

  Future call(JsonApiController controller) =>
      controller.fetchRelationship(this);

  Future toMany(Collection<Identifier> collection) =>
      _server.toMany(_response, route, collection);

  Future toOne(Identifier id) => _server.toOne(_response, route, id);
}

class ReplaceRelationship extends JsonApiRequest {
  final RelationshipRoute route;

  ReplaceRelationship(HttpRequest request, this.route) : super(request);

  Future<Relationship> relationship() async => Relationship.fromJson(
      json.decode(await _request.transform(utf8.decoder).join()));

  Future call(JsonApiController controller) =>
      controller.replaceRelationship(this);

  Future noContent() => _server.write(_response, 204);

  Future toMany(Collection<Identifier> collection) =>
      _server.toMany(_response, route, collection);

  Future toOne(Identifier id) => _server.toOne(_response, route, id);
}

class AddToRelationship extends JsonApiRequest {
  final RelationshipRoute route;

  AddToRelationship(HttpRequest request, this.route) : super(request);

  Future<ToMany> relationship() async => ToMany.fromJson(
      json.decode(await _request.transform(utf8.decoder).join()));

  Future call(JsonApiController controller) =>
      controller.addToRelationship(this);

  Future toMany(Collection<Identifier> collection) =>
      _server.toMany(_response, route, collection);
}

class FetchResource extends JsonApiRequest {
  final ResourceRoute route;

  FetchResource(HttpRequest request, this.route) : super(request);

  Future call(JsonApiController controller) => controller.fetchResource(this);

  Future resource(Resource resource) =>
      _server.resource(_response, route, resource);
}

class DeleteResource extends JsonApiRequest {
  final ResourceRoute route;

  DeleteResource(HttpRequest request, this.route) : super(request);

  Future call(JsonApiController controller) => controller.deleteResource(this);

  Future noContent() => _server.write(_response, 204);

  Future meta(Map<String, Object> meta) => _server.meta(_response, route, meta);
}

class CreateResource extends JsonApiRequest {
  final CollectionRoute route;

  CreateResource(HttpRequest request, this.route) : super(request);

  Future<Resource> resource() async => ResourceDocument.fromJson(
          json.decode(await _request.transform(utf8.decoder).join()))
      .resourceObject
      .toResource();

  Future call(JsonApiController controller) => controller.createResource(this);

  Future created(Resource resource) =>
      _server.created(_response, route, resource);

  Future conflict(List<ErrorObject> errors) =>
      _server.error(_response, 409, errors);

  Future noContent() => _server.write(_response, 204);
}

class UpdateResource extends JsonApiRequest {
  final ResourceRoute route;

  UpdateResource(HttpRequest request, this.route) : super(request);

  Future<Resource> resource() async => ResourceDocument.fromJson(
          json.decode(await _request.transform(utf8.decoder).join()))
      .resourceObject
      .toResource();

  Future call(JsonApiController controller) => controller.updateResource(this);

  Future updated(Resource resource) =>
      _server.resource(_response, route, resource);

  Future conflict(List<ErrorObject> errors) =>
      _server.error(_response, 409, errors);

  Future forbidden(List<ErrorObject> errors) =>
      _server.error(_response, 403, errors);

  Future noContent() => _server.write(_response, 204);
}

class JsonApiServer {
  final UrlBuilder url;
  final String allowOrigin;

  JsonApiServer(this.url, {this.allowOrigin = '*'});

  Future write(HttpResponse response, int status,
      {Document document, Map<String, String> headers = const {}}) {
    response.statusCode = status;
    headers.forEach(response.headers.add);
    if (allowOrigin != null) {
      response.headers.set('Access-Control-Allow-Origin', allowOrigin);
    }
    if (document != null) {
      response.write(json.encode(document));
    }
    return response.close();
  }

  Future collection(HttpResponse response, CollectionRoute route,
          Collection<Resource> collection) =>
      write(response, 200,
          document: CollectionDocument(
              collection.elements.map(ResourceObject.fromResource),
              self: Link(route.print(url, params: collection.page?.parameters)),
              pagination: Pagination.fromMap(collection.page.mapPages(
                  (_) => Link(route.print(url, params: _?.parameters))))));

  Future error(HttpResponse response, int status, List<ErrorObject> errors) =>
      write(response, status, document: ErrorDocument(errors));

  Future relatedCollection(HttpResponse response, RelatedRoute route,
          Collection<Resource> collection) =>
      write(response, 200,
          document:
              CollectionDocument(collection.map(ResourceObject.fromResource)));

  Future relatedResource(
          HttpResponse response, RelatedRoute route, Resource resource) =>
      write(response, 200,
          document: ResourceDocument(ResourceObject.fromResource(resource)));

  Future resource(
          HttpResponse response, ResourceRoute route, Resource resource) =>
      write(response, 200,
          document: ResourceDocument(ResourceObject.fromResource(resource)));

  Future toMany(HttpResponse response, RelationshipRoute route,
          Collection<Identifier> collection) =>
      write(response, 200,
          document: ToMany(collection.map(IdentifierObject.fromIdentifier)));

  Future toOne(HttpResponse response, RelationshipRoute route, Identifier id) =>
      write(response, 200,
          document: ToOne(nullable(IdentifierObject.fromIdentifier)(id)));

  Future meta(HttpResponse response, ResourceRoute route,
          Map<String, Object> meta) =>
      write(response, 200, document: MetaDocument(meta));

  Future created(
          HttpResponse response, CollectionRoute route, Resource resource) =>
      write(response, 201,
          document: ResourceDocument(ResourceObject.fromResource(resource)),
          headers: {
            'Location': url.resource(resource.type, resource.id).toString()
          });
}

abstract class JsonApiController {
  Future fetchCollection(FetchCollection request);

  Future fetchRelated(FetchRelated request);

  Future fetchResource(FetchResource request);

  Future fetchRelationship(FetchRelationship request);

  Future deleteResource(DeleteResource request);

  Future createResource(CreateResource request);

  Future updateResource(UpdateResource request);

  Future replaceRelationship(ReplaceRelationship request);

  Future addToRelationship(AddToRelationship request);
}

class Collection<T> {
  Iterable<T> elements;
  final Page page;

  Collection(this.elements, {this.page});

  Iterable<K> map<K>(K f(T t)) => elements.map(f);
}
