import 'package:json_api/src/server/request/page.dart';

/// Pagination strategy determines how pagination information is encoded in the
/// URL query parameter
abstract class PaginationStrategy {
  int limit(Page page);

  int offset(Page page);

  Page first();

  Page last(int total);

  Page next(Page page, [int total]);

  Page prev(Page page);
}
