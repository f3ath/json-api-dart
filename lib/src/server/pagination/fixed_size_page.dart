import 'package:json_api/src/server/pagination/pagination_strategy.dart';
import 'package:json_api/src/server/query/page.dart';

class FixedSizePage implements PaginationStrategy {
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
