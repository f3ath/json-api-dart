import 'dart:async';

import 'package:json_api/src/link.dart';

/// An object which can be encoded as URI query parameters
abstract class QueryParameters {
  Map<String, String> get parameters;
}

/// Fields to include in sparse fieldsets
/// https://jsonapi.org/format/#fetching-sparse-fieldsets
abstract class Fields implements QueryParameters {}

/// Sorting applied to a resource collection
/// https://jsonapi.org/format/#fetching-sorting
abstract class Sort implements QueryParameters {}

/// Pagination
/// https://jsonapi.org/format/#fetching-pagination
abstract class Page implements QueryParameters {
  /// Next page or null
  Page get next;

  /// Previous page or null
  Page get prev;

  /// First page or null
  Page get first;

  /// Last page or null
  Page get last;
}

/// Filtering data
/// https://jsonapi.org/format/#fetching-filtering
abstract class Filter implements QueryParameters {}

/// Route object
abstract class Route {
  FutureOr<Response> handle<Request, Response>(
      Controller<Request, Response> controller, Request request);
}

/// Route to a resource collection
class CollectionRoute implements Route {
  /// Collection type
  final String type;

  /// Filtering for sparse fieldsets
  final Fields fields;

  /// Pagination
  final Page page;

  /// Sorting
  final Sort sort;

  /// Filtering
  final Filter filter;

  /// Request method
  final String method;

  CollectionRoute(this.type,
      {this.page, this.sort, this.fields, this.filter, this.method}) {
    ArgumentError.checkNotNull(type, 'type');
  }

  CollectionRoute replace(
          {String type,
          Page page,
          Sort sort,
          Fields fields,
          Filter filter,
          String method}) =>
      CollectionRoute(type ?? this.type,
          page: page ?? this.page,
          sort: sort ?? this.sort,
          fields: fields ?? this.fields,
          filter: filter ?? this.filter,
          method: method ?? this.method);

  Link link(LinkFactory link) {
    final params = <String, String>{};
    [filter, fields, sort, page]
        .forEach((_) => params.addAll(_?.parameters ?? {}));
    return link.collection(type, queryParameters: params);
  }

  FutureOr<Response> handle<Request, Response>(
          Controller<Request, Response> controller, Request request) =>
      controller.fetchCollection(this, request);
}

/// Route to a resource
class ResourceRoute implements Route {
  final String type;
  final String id;

  /// Request method
  final String method;

  ResourceRoute(this.type, this.id, {this.method}) {
    ArgumentError.checkNotNull(type, 'type');
    ArgumentError.checkNotNull(id, 'id');
  }

  FutureOr<Response> handle<Request, Response>(
          Controller<Request, Response> controller, Request request) =>
      controller.fetchResource(this, request);
}

/// Route to a related object
class RelatedRoute implements Route {
  final String type;
  final String id;
  final String name;

  /// Request method
  final String method;

  RelatedRoute(this.type, this.id, this.name, {this.method}) {
    ArgumentError.checkNotNull(type, 'type');
    ArgumentError.checkNotNull(id, 'id');
    ArgumentError.checkNotNull(name, 'name');
  }

  FutureOr<Response> handle<Request, Response>(
          Controller<Request, Response> controller, Request request) =>
      controller.fetchRelated(this, request);
}

/// Route to a relationship
class RelationshipRoute implements Route {
  final String type;
  final String id;
  final String name;

  /// Request method
  final String method;

  RelationshipRoute(this.type, this.id, this.name, {this.method}) {
    ArgumentError.checkNotNull(type, 'type');
    ArgumentError.checkNotNull(id, 'id');
    ArgumentError.checkNotNull(name, 'name');
  }

  FutureOr<Response> handle<Request, Response>(
          Controller<Request, Response> controller, Request request) =>
      controller.fetchRelationship(this, request);
}

abstract class Controller<Request, Response> {
  FutureOr<Response> fetchCollection(CollectionRoute route, Request request);

  FutureOr<Response> fetchResource(ResourceRoute r, Request request);

  FutureOr<Response> fetchRelated(RelatedRoute r, Request request);

  FutureOr<Response> fetchRelationship(RelationshipRoute r, Request request);
}

abstract class Router<Request> {
  FutureOr<Route> parse(Request request);
}

class RouterException implements Exception {
  final String message;

  RouterException(this.message);
}

class StandardRouterRequest {
  final String method;
  final Uri uri;

  StandardRouterRequest(this.method, this.uri);
}

/// A Router following the standard conventions
class StandardRouter implements Router<StandardRouterRequest> {
  @override
  parse(StandardRouterRequest rq) {
    final seg = rq.uri.pathSegments;
    switch (seg.length) {
      case 1:
        return CollectionRoute(seg[0], method: rq.method);
      case 2:
        return ResourceRoute(seg[0], seg[1], method: rq.method);
      case 3:
        return RelatedRoute(seg[0], seg[1], seg[2], method: rq.method);
      case 4:
        if (seg[2] == 'relationships') {
          return RelationshipRoute(seg[0], seg[1], seg[3], method: rq.method);
        }
    }
    throw RouterException('Can not parse URI: ${rq.uri}');
  }
}
