import 'dart:collection';
import 'dart:convert';

import 'package:json_api/json_api.dart';
import 'package:json_api/src/document.dart';
import 'package:json_api_common/http.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';

class FetchCollection with IterableMixin<ResourceWithIdentity> {
  factory FetchCollection(HttpResponse http) {
    final document = DataDocument.fromJson(jsonDecode(http.body));
    return FetchCollection._(http,
        resources: ResourceCollection.fromJson(document.data),
        included: ResourceCollection(document.included(orElse: () => [])),
        links: document.links);
  }

  FetchCollection._(this.http,
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

class FetchPrimaryResource {
  factory FetchPrimaryResource(HttpResponse http) {
    final document = DataDocument.fromJson(jsonDecode(http.body));
    return FetchPrimaryResource._(
        http, ResourceWithIdentity.fromJson(document.data),
        included: ResourceCollection(document.included(orElse: () => [])),
        links: document.links);
  }

  FetchPrimaryResource._(this.http, this.resource,
      {ResourceCollection included, Map<String, Link> links = const {}})
      : links = Map.unmodifiable(links ?? const {}),
        included = included ?? ResourceCollection(const []);

  final HttpResponse http;
  final ResourceWithIdentity resource;
  final ResourceCollection included;
  final Map<String, Link> links;
}

class CreateResource {
  factory CreateResource(HttpResponse http) {
    final document = DataDocument.fromJson(jsonDecode(http.body));
    return CreateResource._(http, ResourceWithIdentity.fromJson(document.data),
        links: document.links);
  }

  CreateResource._(this.http, this.resource,
      {Map<String, Link> links = const {}})
      : links = Map.unmodifiable(links ?? const {});

  final HttpResponse http;
  final Map<String, Link> links;
  final ResourceWithIdentity resource;
}

class UpdateResource {
  factory UpdateResource(HttpResponse http) {
    if (http.body.isEmpty) {
      return UpdateResource._empty(http);
    }
    final document = DataDocument.fromJson(jsonDecode(http.body));
    return UpdateResource._(http, ResourceWithIdentity.fromJson(document.data),
        links: document.links);
  }

  UpdateResource._(this.http, ResourceWithIdentity resource,
      {Map<String, Link> links = const {}})
      : _resource = Just(resource),
        links = Map.unmodifiable(links ?? const {});

  UpdateResource._empty(this.http)
      : _resource = Nothing<ResourceWithIdentity>(),
        links = const {};

  final HttpResponse http;
  final Map<String, Link> links;
  final Maybe<ResourceWithIdentity> _resource;

  ResourceWithIdentity resource({ResourceWithIdentity Function() orElse}) =>
      _resource.orGet(() =>
          Maybe(orElse).orThrow(() => StateError('No content returned'))());
}

class DeleteResource {
  DeleteResource(this.http)
      : meta = http.body.isEmpty
            ? const {}
            : Document.fromJson(jsonDecode(http.body)).meta;

  final HttpResponse http;
  final Map<String, Object> meta;
}

class FetchRelationship<R extends Relationship> {
  FetchRelationship(this.http)
      : relationship = Relationship.fromJson(jsonDecode(http.body)).as<R>();

  final HttpResponse http;
  final R relationship;
}

class UpdateRelationship<R extends Relationship> {
  UpdateRelationship(this.http)
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

class FetchRelatedResource {
  factory FetchRelatedResource(HttpResponse http) {
    final document = DataDocument.fromJson(jsonDecode(http.body));
    return FetchRelatedResource._(
        http, Maybe(document.data).map(ResourceWithIdentity.fromJson),
        included: ResourceCollection(document.included(orElse: () => [])),
        links: document.links);
  }

  FetchRelatedResource._(this.http, this._resource,
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
