import 'dart:async';

import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/link_factory.dart';
import 'package:json_api/src/server/query_parameters.dart';

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
