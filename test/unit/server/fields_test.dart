import 'package:json_api/src/query/fields.dart';
import 'package:test/test.dart';

void main() {
  test('Can decode url', () {
    final uri = Uri.parse(
        '/articles?include=author&fields[articles]=title,body&fields[people]=name');
    final fields = Fields.decode(uri.queryParametersAll);
    expect(fields['articles'], ['title', 'body']);
    expect(fields['people'], ['name']);
  });
}
