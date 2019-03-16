
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

  Map<String, String> get queryParameters;

  Map<String, T> mapPages<T>(T f(Page p)) =>
      asMap.map((name, page) => MapEntry(name, f(page)));

  Map<String, Page> get asMap =>
      {'first': first, 'last': last, 'prev': prev, 'next': next};
}
