import 'package:json_api/src/query/page.dart';
import 'package:json_api/src/server/pagination.dart';
import 'package:test/test.dart';

void main() {
  test('page size must be posititve', () {
    expect(() => FixedSizePage(0), throwsArgumentError);
  });

  test('no pages after last', () {
    final page = Page({'number': '4'});
    final pagination = FixedSizePage(3);
    expect(pagination.next(page, 10), isNull);
  });

  test('no pages before first', () {
    final page = Page({'number': '1'});
    final pagination = FixedSizePage(3);
    expect(pagination.prev(page), isNull);
  });

  test('pagination', () {
    final page = Page({'number': '4'});
    final pagination = FixedSizePage(3);
    expect(pagination.prev(page)['number'], '3');
    expect(pagination.next(page, 100)['number'], '5');
    expect(pagination.first()['number'], '1');
    expect(pagination.last(100)['number'], '34');
  });
}
