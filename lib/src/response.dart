import 'dart:collection';
import 'dart:convert';

import 'package:json_api/json_api.dart';
import 'package:json_api/src/document.dart';
import 'package:json_api_common/http.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';

class FetchCollection with IterableMixin<ResourceWithIdentity> {
  factory FetchCollection(HttpResponse http) {
    final document = Document(jsonDecode(http.body));
    return FetchCollection._(http,
        resources: IdentityCollection(document.data
            .cast<List>()
            .map((_) => _.map(ResourceWithIdentity.fromJson))
            .or(const [])),
        included: IdentityCollection(document.included.or([])),
        links: document.links.or(const {}));
  }

  FetchCollection._(this.http,
      {IdentityCollection<ResourceWithIdentity> resources,
      IdentityCollection<ResourceWithIdentity> included,
      Map<String, Link> links = const {}})
      : resources = resources ?? IdentityCollection(const []),
        links = Map.unmodifiable(links ?? const {}),
        included = included ?? IdentityCollection(const []);

  final HttpResponse http;
  final IdentityCollection<ResourceWithIdentity> resources;
  final IdentityCollection<ResourceWithIdentity> included;
  final Map<String, Link> links;

  @override
  Iterator<ResourceWithIdentity> get iterator => resources.iterator;
}

class FetchPrimaryResource {
  factory FetchPrimaryResource(HttpResponse http) {
    final document = Document(jsonDecode(http.body));
    return FetchPrimaryResource._(
        http,
        document.data
            .map(ResourceWithIdentity.fromJson)
            .orThrow(() => ArgumentError('Invalid response')),
        included: IdentityCollection(document.included.or([])),
        links: document.links.or(const {}));
  }

  FetchPrimaryResource._(this.http, this.resource,
      {IdentityCollection included, Map<String, Link> links = const {}})
      : links = Map.unmodifiable(links ?? const {}),
        included = included ?? IdentityCollection(const []);

  final HttpResponse http;
  final ResourceWithIdentity resource;
  final IdentityCollection included;
  final Map<String, Link> links;
}

class CreateResource {
  factory CreateResource(HttpResponse http) {
    final document = Document(jsonDecode(http.body));
    return CreateResource._(
        http,
        document.data
            .map(ResourceWithIdentity.fromJson)
            .orThrow(() => ArgumentError('Invalid response')),
        links: document.links.or(const {}));
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
    final document = Document(jsonDecode(http.body));
    return UpdateResource._(
        http,
        document.data
            .map(ResourceWithIdentity.fromJson)
            .orThrow(() => ArgumentError('Invalid response')),
        links: document.links.or(const {}));
  }

  UpdateResource._(this.http, ResourceWithIdentity resource,
      {Map<String, Link> links = const {}})
      : resource = Just(resource),
        links = Map.unmodifiable(links ?? const {});

  UpdateResource._empty(this.http)
      : resource = Nothing<ResourceWithIdentity>(),
        links = const {};

  final HttpResponse http;
  final Map<String, Link> links;
  final Maybe<ResourceWithIdentity> resource;
}

class DeleteResource {
  DeleteResource(this.http)
      : meta = http.body.isEmpty
            ? const {}
            : Document(jsonDecode(http.body)).meta.or(const {});

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
      : relationship = Maybe(http.body)
            .filter((_) => _.isNotEmpty)
            .map(jsonDecode)
            .map(Relationship.fromJson)
            .map((_) => _.as<R>());

  final HttpResponse http;
  final Maybe<R> relationship;
}

class FetchRelatedResource {
  factory FetchRelatedResource(HttpResponse http) {
    final document = Document(jsonDecode(http.body));
    return FetchRelatedResource._(
        http, document.data.map(ResourceWithIdentity.fromJson),
        included: IdentityCollection(document.included.or([])),
        links: document.links.or(const {}));
  }

  FetchRelatedResource._(this.http, this.resource,
      {IdentityCollection included, Map<String, Link> links = const {}})
      : links = Map.unmodifiable(links ?? const {}),
        included = included ?? IdentityCollection(const []);

  final Maybe<ResourceWithIdentity> resource;
  final HttpResponse http;
  final IdentityCollection included;
  final Map<String, Link> links;
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

    return RequestFailure(http,
        errors: Maybe(jsonDecode(http.body))
            .cast<Map>()
            .flatMap((_) => Maybe(_['errors']))
            .cast<List>()
            .map((_) => _.map(ErrorObject.fromJson))
            .or([]));
  }

  final HttpResponse http;
}
