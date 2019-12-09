import 'package:json_api/query.dart';
import 'package:test/test.dart';

void main() {
  final page = Page({"limit": "10", "offset": "3"});
  final include = Include(["foo", "bar"]);
  final fields = Fields({
    "foo": ["bar"]
  });
  final sort = Sort().asc("foo").desc("bar");

  test('query can be constructed of independent elements', () {
    final query =
        Query(page: page, include: include, fields: fields, sort: sort);

    expect(query.addToUri(Uri.parse('http://example.com')).toString(),
        'http://example.com?page%5Blimit%5D=10&page%5Boffset%5D=3&include=foo%2Cbar&fields%5Bfoo%5D=bar&sort=foo%2C-bar');
  });

  test('query elements are optional', () {
    final query = Query(page: page, fields: fields);

    expect(query.addToUri(Uri.parse('http://example.com')).toString(),
        'http://example.com?page%5Blimit%5D=10&page%5Boffset%5D=3&fields%5Bfoo%5D=bar');
  });

  test('query can be empty, in this case it does not change the uri', () {
    final query = Query();

    expect(query.addToUri(Uri.parse('http://example.com')).toString(),
        'http://example.com');
  });
}
