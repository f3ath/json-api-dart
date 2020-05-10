import 'dart:collection';

import 'package:json_api/client.dart';
import 'package:json_api/http.dart';
import 'package:json_api/src/client/document.dart';
import 'package:json_api/src/client/status_code.dart';
import 'package:json_api/src/maybe.dart';

class FetchCollectionResponse with IterableMixin<Resource> {
  FetchCollectionResponse(this.http,
      {ResourceCollection resources,
      ResourceCollection included,
      Map<String, Link> links = const {}})
      : resources = resources ?? ResourceCollection(const []),
        links = Map.unmodifiable(links ?? const {}),
        included = included ?? ResourceCollection(const []);

  static FetchCollectionResponse fromHttp(HttpResponse http) {
    final document = ResponseDocument.decode(http.body);
    return FetchCollectionResponse(http,
        resources: document.resources,
        included: document.included,
        links: document.links);
  }

  final HttpResponse http;
  final ResourceCollection resources;
  final ResourceCollection included;
  final Map<String, Link> links;

  @override
  Iterator<Resource> get iterator => resources.iterator;
}

class FetchPrimaryResourceResponse {
  FetchPrimaryResourceResponse(this.http, this.resource,
      {ResourceCollection included, Map<String, Link> links = const {}})
      : links = Map.unmodifiable(links ?? const {}),
        included = included ?? ResourceCollection(const []);

  static FetchPrimaryResourceResponse fromHttp(HttpResponse http) {
    final document = ResponseDocument.decode(http.body);
    return FetchPrimaryResourceResponse(http, document.resource,
        included: document.included, links: document.links);
  }

  final HttpResponse http;
  final Resource resource;
  final ResourceCollection included;
  final Map<String, Link> links;
}

class CreateResourceResponse {
  CreateResourceResponse(this.http, this.resource,
      {Map<String, Link> links = const {}})
      : links = Map.unmodifiable(links ?? const {});

  static CreateResourceResponse fromHttp(HttpResponse http) {
    final document = ResponseDocument.decode(http.body);
    return CreateResourceResponse(http, document.resource,
        links: document.links);
  }

  final HttpResponse http;
  final Map<String, Link> links;
  final Resource resource;
}

class ResourceResponse {
  ResourceResponse(this.http, Resource resource,
      {Map<String, Link> links = const {}})
      : _resource = Just(resource),
        links = Map.unmodifiable(links ?? const {});

  ResourceResponse.empty(this.http)
      : _resource = Nothing<Resource>(),
        links = const {};

  static ResourceResponse fromHttp(HttpResponse http) {
    if (StatusCode(http.statusCode).isNoContent) {
      return ResourceResponse.empty(http);
    }
    final document = ResponseDocument.decode(http.body);
    return ResourceResponse(http, document.resource, links: document.links);
  }

  final HttpResponse http;
  final Map<String, Link> links;
  final Maybe<Resource> _resource;

  Resource resource({Resource Function() orElse}) => _resource.orGet(
      () => Maybe(orElse).orThrow(() => StateError('No content returned'))());
}

class DeleteResourceResponse {
  DeleteResourceResponse(this.http, Map<String, Object> meta)
      : meta = Map.unmodifiable(meta);

  DeleteResourceResponse.empty(this.http) : meta = const {};

  static DeleteResourceResponse fromHttp(HttpResponse http) {
    if (StatusCode(http.statusCode).isNoContent) {
      return DeleteResourceResponse.empty(http);
    }
    final document = ResponseDocument.decode(http.body);
    return DeleteResourceResponse(http, document.meta);
  }

  final HttpResponse http;
  final Map<String, Object> meta;
}

class FetchRelationshipResponse<R extends Relationship> {
  FetchRelationshipResponse(this.http, this.relationship);

  static FetchRelationshipResponse fromHttp<R extends Relationship>(
          HttpResponse http) =>
      FetchRelationshipResponse(
          http, ResponseDocument.decode(http.body).relationship.as<R>());

  final HttpResponse http;
  final R relationship;
}

class RelationshipResponse<R extends Relationship> {
  RelationshipResponse(this.http, R relationship)
      : _relationship = Just(relationship);

  RelationshipResponse.empty(this.http) : _relationship = Nothing<R>();

  static RelationshipResponse<R> fromHttp<R extends Relationship>(
          HttpResponse http) =>
      http.body.isEmpty
          ? RelationshipResponse<R>.empty(http)
          : RelationshipResponse(
              http, ResponseDocument.decode(http.body).relationship.as<R>());

  final HttpResponse http;
  final Maybe<R> _relationship;

  R relationship({R Function() orElse}) => _relationship.orGet(
      () => Maybe(orElse).orThrow(() => StateError('No content returned'))());
}

class FetchRelatedResourceResponse {
  FetchRelatedResourceResponse(this.http, Resource resource,
      {ResourceCollection included, Map<String, Link> links = const {}})
      : _resource = Just(resource),
        links = Map.unmodifiable(links ?? const {}),
        included = included ?? ResourceCollection(const []);

  FetchRelatedResourceResponse.empty(this.http,
      {ResourceCollection included, Map<String, Link> links = const {}})
      : _resource = Nothing<Resource>(),
        links = Map.unmodifiable(links ?? const {}),
        included = included ?? ResourceCollection(const []);

  static FetchRelatedResourceResponse fromHttp(HttpResponse http) {
    final document = ResponseDocument.decode(http.body);
    if (document.hasData) {
      return FetchRelatedResourceResponse(http, document.resource,
          included: document.included, links: document.links);
    }
    return FetchRelatedResourceResponse.empty(http,
        included: document.included, links: document.links);
  }

  final HttpResponse http;
  final Maybe<Resource> _resource;

  Resource resource({Resource Function() orElse}) => _resource.orGet(() =>
      Maybe(orElse).orThrow(() => StateError('Related resource is empty'))());
  final ResourceCollection included;
  final Map<String, Link> links;
}

class RequestFailure {
  RequestFailure(this.http, {Iterable<ErrorObject> errors = const []})
      : errors = List.unmodifiable(errors ?? const []);
  final List<ErrorObject> errors;

  static RequestFailure fromHttp(HttpResponse http) =>
      RequestFailure(http, errors: ResponseDocument.decode(http.body).errors);

  final HttpResponse http;
}
