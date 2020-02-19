import 'package:json_api/src/query/page.dart';

/// Pagination strategy determines how pagination information is encoded in the
/// URL query parameters
abstract class Pagination {
  /// Number of elements per page. Null for unlimited.
  int limit(Page page);

  /// The page offset.
  int offset(Page page);

  /// Link to the first page. Null if not supported.
  Page first();

  /// Reference to the last page. Null if not supported.
  Page last(int total);

  /// Reference to the next page. Null if not supported or if current page is the last.
  Page next(Page page, [int total]);

  /// Reference to the first page. Null if not supported or if current page is the first.
  Page prev(Page page);
}

/// No pagination. The server will not be able to produce pagination links.
class NoPagination implements Pagination {
  const NoPagination();

  @override
  Page first() => null;

  @override
  Page last(int total) => null;

  @override
  int limit(Page page) => -1;

  @override
  Page next(Page page, [int total]) => null;

  @override
  int offset(Page page) => 0;

  @override
  Page prev(Page page) => null;
}

/// Pages of fixed [size].
class FixedSizePage implements Pagination {
  final int size;

  FixedSizePage(this.size) {
    if (size < 1) throw ArgumentError();
  }

  @override
  Page first() => _page(1);

  @override
  Page last(int total) => _page((total - 1) ~/ size + 1);

  @override
  Page next(Page page, [int total]) {
    final number = _number(page);
    if (total == null || number * size < total) {
      return _page(number + 1);
    }
    return null;
  }

  @override
  Page prev(Page page) {
    final number = _number(page);
    if (number > 1) return _page(number - 1);
    return null;
  }

  @override
  int limit(Page page) => size;

  @override
  int offset(Page page) => size * (_number(page) - 1);

  int _number(Page page) => int.parse(page['number'] ?? '1');

  Page _page(int number) => Page({'number': number.toString()});
}
