import 'package:json_api/src/query/sort.dart';
import 'package:test/test.dart';

void main() {
  test('emptiness', () {
    expect(Sort().isEmpty, isTrue);
    expect(Sort().isNotEmpty, isFalse);
    expect(Sort(['-created']).isEmpty, isFalse);
    expect(Sort(['-created']).isNotEmpty, isTrue);
  });

  test('Can decode url without duplicate keys', () {
    final uri = Uri.parse('/articles?sort=-created,title');
    final sort = Sort.fromUri(uri);
    expect(sort.length, 2);
    expect(sort.first.name, 'created');
    expect(sort.last.name, 'title');
  });

  test('Can decode url with duplicate keys', () {
    final uri = Uri.parse('/articles?sort=-created&sort=title');
    final sort = Sort.fromUri(uri);
    expect(sort.length, 2);
    expect(sort.first.name, 'created');
    expect(sort.last.name, 'title');
  });

  test('Can convert to query parameters', () {
    expect(Sort(['-created', 'title']).asQueryParameters,
        {'sort': '-created,title'});
  });
}
