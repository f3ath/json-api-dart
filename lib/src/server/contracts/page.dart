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

  Map<String, String> get parameters;

  Map<String, T> map<T>(T f(Page p)) => ({
        'first': first,
        'last': last,
        'prev': prev,
        'next': next
      }..removeWhere((_, v) => v == null))
          .map((name, page) => MapEntry(name, f(page)));
}
