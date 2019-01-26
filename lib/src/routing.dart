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

/// Route to a resource collection
class CollectionRoute {
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

  CollectionRoute(this.type, {this.page, this.sort, this.fields, this.filter}) {
    ArgumentError.checkNotNull(type, 'type');
  }

  CollectionRoute get nextPage => page?.next == null
      ? null
      : CollectionRoute(type,
          page: page.next, sort: sort, fields: fields, filter: filter);

  CollectionRoute get prevPage => page?.prev == null
      ? null
      : CollectionRoute(type,
          page: page.prev, sort: sort, fields: fields, filter: filter);

  CollectionRoute get firstPage => page?.first == null
      ? null
      : CollectionRoute(type,
          page: page.first, sort: sort, fields: fields, filter: filter);

  CollectionRoute get lastPage => page?.last == null
      ? null
      : CollectionRoute(type,
          page: page.last, sort: sort, fields: fields, filter: filter);

  Link link(LinkFactory link) {
    final params = <String, String>{};
    [filter, fields, sort, page]
        .forEach((_) => params.addAll(_?.parameters ?? {}));
    return link.collection(type, queryParameters: params);
  }
}

/// Route to a resource
class ResourceRoute {
  final String type;
  final String id;

  ResourceRoute(this.type, this.id) {
    ArgumentError.checkNotNull(type, 'type');
    ArgumentError.checkNotNull(id, 'id');
  }
}

/// Route to a related object
class RelatedRoute {
  final String type;
  final String id;
  final String name;

  RelatedRoute(this.type, this.id, this.name) {
    ArgumentError.checkNotNull(type, 'type');
    ArgumentError.checkNotNull(id, 'id');
    ArgumentError.checkNotNull(name, 'name');
  }
}

/// Route to a relationship
class RelationshipRoute {
  final String type;
  final String id;
  final String name;

  RelationshipRoute(this.type, this.id, this.name) {
    ArgumentError.checkNotNull(type, 'type');
    ArgumentError.checkNotNull(id, 'id');
    ArgumentError.checkNotNull(name, 'name');
  }
}
