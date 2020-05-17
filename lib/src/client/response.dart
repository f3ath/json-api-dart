import 'dart:collection';
import 'dart:convert';

import 'package:json_api/client.dart';
import 'package:json_api/http.dart';
import 'package:json_api/src/client/document.dart';
import 'package:json_api/src/maybe.dart';

class FetchCollectionResponse with IterableMixin<ResourceWithIdentity> {
  factory FetchCollectionResponse(HttpResponse http) {
    final document = DataDocument.fromJson(jsonDecode(http.body));
    return FetchCollectionResponse._(http,
        resources: ResourceCollection.fromJson(document.data),
        included: ResourceCollection(document.included(orElse: () => [])),
        links: document.links);
  }

  FetchCollectionResponse._(this.http,
      {ResourceCollection resources,
      ResourceCollection included,
      Map<String, Link> links = const {}})
      : resources = resources ?? ResourceCollection(const []),
        links = Map.unmodifiable(links ?? const {}),
        included = included ?? ResourceCollection(const []);

  final HttpResponse http;
  final ResourceCollection resources;
  final ResourceCollection included;
  final Map<String, Link> links;

  @override
  Iterator<ResourceWithIdentity> get iterator => resources.iterator;
}

class FetchPrimaryResourceResponse {
  factory FetchPrimaryResourceResponse(HttpResponse http) {
    final document = DataDocument.fromJson(jsonDecode(http.body));
    return FetchPrimaryResourceResponse._(
        http, ResourceWithIdentity.fromJson(document.data),
        included: ResourceCollection(document.included(orElse: () => [])),
        links: document.links);
  }

  FetchPrimaryResourceResponse._(this.http, this.resource,
      {ResourceCollection included, Map<String, Link> links = const {}})
      : links = Map.unmodifiable(links ?? const {}),
        included = included ?? ResourceCollection(const []);

  final HttpResponse http;
  final ResourceWithIdentity resource;
  final ResourceCollection included;
  final Map<String, Link> links;
}

class CreateResourceResponse {
  factory CreateResourceResponse(HttpResponse http) {
    final document = DataDocument.fromJson(jsonDecode(http.body));
    return CreateResourceResponse._(
        http, ResourceWithIdentity.fromJson(document.data),
        links: document.links);
  }

  CreateResourceResponse._(this.http, this.resource,
      {Map<String, Link> links = const {}})
      : links = Map.unmodifiable(links ?? const {});

  final HttpResponse http;
  final Map<String, Link> links;
  final ResourceWithIdentity resource;
}

class ResourceResponse {
  factory ResourceResponse(HttpResponse http) {
    if (http.body.isEmpty) {
      return ResourceResponse._empty(http);
    }
    final document = DataDocument.fromJson(jsonDecode(http.body));
    return ResourceResponse._(
        http, ResourceWithIdentity.fromJson(document.data),
        links: document.links);
  }

  ResourceResponse._(this.http, ResourceWithIdentity resource,
      {Map<String, Link> links = const {}})
      : _resource = Just(resource),
        links = Map.unmodifiable(links ?? const {});

  ResourceResponse._empty(this.http)
      : _resource = Nothing<ResourceWithIdentity>(),
        links = const {};

  final HttpResponse http;
  final Map<String, Link> links;
  final Maybe<ResourceWithIdentity> _resource;

  ResourceWithIdentity resource({ResourceWithIdentity Function() orElse}) =>
      _resource.orGet(() =>
          Maybe(orElse).orThrow(() => StateError('No content returned'))());
}

class DeleteResourceResponse {
  DeleteResourceResponse(this.http)
      : meta = http.body.isEmpty
            ? const {}
            : Document.fromJson(jsonDecode(http.body)).meta;

  final HttpResponse http;
  final Map<String, Object> meta;
}

class FetchRelationshipResponse<R extends Relationship> {
  FetchRelationshipResponse(this.http)
      : relationship = Relationship.fromJson(jsonDecode(http.body)).as<R>();

  final HttpResponse http;
  final R relationship;
}

class UpdateRelationshipResponse<R extends Relationship> {
  UpdateRelationshipResponse(this.http)
      : _relationship = Maybe(http.body)
            .filter((_) => _.isNotEmpty)
            .map(jsonDecode)
            .map(Relationship.fromJson)
            .map((_) => _.as<R>());

  final HttpResponse http;
  final Maybe<R> _relationship;

  R relationship({R Function() orElse}) => _relationship.orGet(
      () => Maybe(orElse).orThrow(() => StateError('No content returned'))());
}

class FetchRelatedResourceResponse {
  factory FetchRelatedResourceResponse(HttpResponse http) {
    final document = DataDocument.fromJson(jsonDecode(http.body));
    return FetchRelatedResourceResponse._(
        http, Maybe(document.data).map(ResourceWithIdentity.fromJson),
        included: ResourceCollection(document.included(orElse: () => [])),
        links: document.links);
  }

  FetchRelatedResourceResponse._(this.http, this._resource,
      {ResourceCollection included, Map<String, Link> links = const {}})
      : links = Map.unmodifiable(links ?? const {}),
        included = included ?? ResourceCollection(const []);

  final Maybe<ResourceWithIdentity> _resource;
  final HttpResponse http;
  final ResourceCollection included;
  final Map<String, Link> links;

  ResourceWithIdentity resource({ResourceWithIdentity Function() orElse}) =>
      _resource.orGet(() => Maybe(orElse)
          .orThrow(() => StateError('Related resource is empty'))());
}

class RequestFailure {
  RequestFailure(this.http, {Iterable<ErrorObject> errors = const []})
      : errors = List.unmodifiable(errors ?? const []);
  final List<ErrorObject> errors;

  static RequestFailure fromHttp(HttpResponse http) {
    if (http.body.isEmpty ||
        http.headers['content-type'] != ContentType.jsonApi) {
      return RequestFailure(http);
    }
    final errors = Maybe(jsonDecode(http.body))
        .map((_) => _ is Map ? _ : throw ArgumentError('Invalid json'))
        .map((_) => _['errors'])
        .map((_) => _ is List ? _ : throw ArgumentError('Invalid json'))
        .map((_) => _.map(ErrorObject.fromJson))
        .or([]);

    return RequestFailure(http, errors: errors);
  }

  final HttpResponse http;
}
