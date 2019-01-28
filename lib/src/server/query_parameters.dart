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
