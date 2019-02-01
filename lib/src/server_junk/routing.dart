import 'package:json_api/document.dart';

abstract class CRUDController<Request, Response> {
  Response fetchCollection(Request request, CollectionOperation op);

  Response fetchResource(Request request, ResourceOperation op);

  Response fetchRelated(Request request, RelatedOperation op);

  Response fetchRelationship(Request request, RelationshipOperation op);
}

typedef Rs Handler<Rq, Rs>(Rq request);

abstract class Operation {
  Handler<Rq, Rs> handler<Rq, Rs>(CRUDController<Rq, Rs> c);
}

class CollectionOperation implements Operation {
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

  CollectionOperation(this.type,
      {this.page, this.sort, this.fields, this.filter, this.method}) {
    ArgumentError.checkNotNull(type, 'type');
  }

  Handler<Rq, Rs> handler<Rq, Rs>(CRUDController<Rq, Rs> c) =>
      (_) => c.fetchCollection(_, this);
}

class ResourceOperation implements Operation {
  final String type;
  final String id;

  /// Request method
  final String method;

  ResourceOperation(this.type, this.id, {this.method}) {
    ArgumentError.checkNotNull(type, 'type');
    ArgumentError.checkNotNull(id, 'id');
  }

  Handler<Rq, Rs> handler<Rq, Rs>(CRUDController<Rq, Rs> c) =>
      (_) => c.fetchResource(_, this);
}

class RelatedOperation implements Operation {
  final String type;
  final String id;
  final String name;

  /// Request method
  final String method;

  RelatedOperation(this.type, this.id, this.name, {this.method}) {
    ArgumentError.checkNotNull(type, 'type');
    ArgumentError.checkNotNull(id, 'id');
    ArgumentError.checkNotNull(name, 'name');
  }

  Handler<Rq, Rs> handler<Rq, Rs>(CRUDController<Rq, Rs> c) =>
      (_) => c.fetchRelated(_, this);
}

class RelationshipOperation implements Operation {
  final String type;
  final String id;
  final String name;

  /// Request method
  final String method;

  RelationshipOperation(this.type, this.id, this.name, {this.method}) {
    ArgumentError.checkNotNull(type, 'type');
    ArgumentError.checkNotNull(id, 'id');
    ArgumentError.checkNotNull(name, 'name');
  }

  Handler<Rq, Rs> handler<Rq, Rs>(CRUDController<Rq, Rs> c) =>
      (_) => c.fetchRelationship(_, this);
}

class RoutingException implements Exception {}

abstract class Routing {
  Link collectionLink(String type, {Map<String, String> params});

  Link resourceLink(String type, String id);

  Link relatedLink(String type, String id, String name);

  Link relationshipLink(String type, String id, String name);

  Operation resolveOperation(Uri uri, String method);
}

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
