import 'package:json_api/src/query/page.dart';

/// Pagination strategy determines how pagination information is encoded in the
/// URL query parameters
abstract class PaginationStrategy {
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
