import 'package:json_api/src/query/sort.dart';
import 'package:test/test.dart';

void main() {
  test('Can decode url', () {
    final uri = Uri.parse('/articles?sort=-created,title');
    final sort = Sort.fromUri(uri);
    expect(sort.length, 2);
    expect(sort.first.isDesc, true);
    expect(sort.first.name, 'created');
    expect(sort.last.isAsc, true);
    expect(sort.last.name, 'title');
  });

  test('Can add to uri', () {
    final sort = Sort().desc('created').asc('title');
    final uri = Uri.parse('/articles');
    expect(sort.addTo(uri).toString(), '/articles?sort=-created%2Ctitle');
  });
}
