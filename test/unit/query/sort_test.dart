import 'package:json_api/src/query/sort.dart';
import 'package:test/test.dart';

void main() {
  test('emptiness', () {
    expect(Sort([]).isEmpty, isTrue);
    expect(Sort([]).isNotEmpty, isFalse);
    expect(Sort([Desc('created')]).isEmpty, isFalse);
    expect(Sort([Desc('created')]).isNotEmpty, isTrue);
  });

  test('Can decode url wthout duplicate keys', () {
    final uri = Uri.parse('/articles?sort=-created,title');
    final sort = Sort.fromUri(uri);
    expect(sort.length, 2);
    expect(sort.first.isDesc, true);
    expect(sort.first.name, 'created');
    expect(sort.last.isAsc, true);
    expect(sort.last.name, 'title');
  });

  test('Can decode url with duplicate keys', () {
    final uri = Uri.parse('/articles?sort=-created&sort=title');
    final sort = Sort.fromUri(uri);
    expect(sort.length, 2);
    expect(sort.first.isDesc, true);
    expect(sort.first.name, 'created');
    expect(sort.last.isAsc, true);
    expect(sort.last.name, 'title');
  });

  test('Can add to uri', () {
    final sort = Sort([Desc('created'), Asc('title')]);
    final uri = Uri.parse('/articles');
    expect(sort.addToUri(uri).toString(), '/articles?sort=-created%2Ctitle');
  });
}
