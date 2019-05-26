import 'package:json_api/src/server/_server.dart';
import 'package:test/test.dart';

void main() {
  test('can decode fields', () {
    final uri = Uri.parse(
        '/articles?include=author&fields[articles]=title,body&fields[people]=name');
    final query = uri.queryParametersAll;
    final fields = SparseFields.fromQuery(query);
    expect(fields.fields['articles'], ['title', 'body']);
    expect(fields.fields['people'], ['name']);
  });

  test('can encode fields', () {
    final fields = SparseFields({
      'articles': ['title', 'body'],
      'people': ['name']
    });
    expect(fields.query, {
      'fields[articles]': ['title,body'],
      'fields[people]': ['name']
    });
  });
}
