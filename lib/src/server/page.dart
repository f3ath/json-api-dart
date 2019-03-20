/// Pagination
/// https://jsonapi.org/format/#fetching-pagination
abstract class Page {
  /// Next page or null
  Page get next;

  /// Previous page or null
  Page get prev;

  /// First page or null
  Page get first;

  /// Last page or null
  Page get last;

  Uri addTo(Uri uri) {
    if (queryParameters == null) {
      return uri;
    }
    if (uri.queryParameters == null) {
      return uri.replace(queryParameters: queryParameters);
    }
    return uri.replace(
        queryParameters: {}
          ..addAll(uri.queryParameters)
          ..addAll(queryParameters));
  }

  Map<String, String> get queryParameters;

  Map<String, T> map<T>(T f(Page p)) => ({
        'first': first,
        'last': last,
        'prev': prev,
        'next': next
      }..removeWhere((_, v) => v == null))
          .map((name, page) => MapEntry(name, f(page)));
}
