import 'package:json_api/src/pagination/pagination.dart';
import 'package:json_api/src/query/page.dart';

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
