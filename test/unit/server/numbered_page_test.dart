import 'package:json_api/src/server/_server.dart';
import 'package:test/test.dart';

void main() {
  test('page size must be posititve', () {
    expect(() => NumberedPage(1, 0), throwsArgumentError);
  });

  test('page number must be posititve', () {
    expect(() => NumberedPage(-2, 2), throwsArgumentError);
  });

  test('no pages after last', () {
    expect(NumberedPage(3, 10).next(30), isNull);
  });

  test('no pages before first', () {
    expect(NumberedPage(1, 10).prev(), isNull);
  });

  test('pagination', () {
    expect(NumberedPage(1, 10).first().number, 1);
    expect(NumberedPage(1, 10).prev(), isNull);
    expect(NumberedPage(1, 10).last(9).number, 1);
    expect(NumberedPage(1, 10).last(10).number, 1);
    expect(NumberedPage(1, 10).last(11).number, 2);
    expect(NumberedPage(1, 10).last(99).number, 10);
    expect(NumberedPage(1, 10).last(101).number, 11);
  });
}
