import 'package:json_api/server.dart';
import 'package:test/test.dart';

void main() {
  final uri = Uri.parse('/articles/1?include=author,comments.author');
  final query = uri.queryParametersAll;
  final include = InclusionRequest.fromQuery(query);

  test('can decode query', () {
    expect(include.relationships[0].elements, ['author']);
    expect(include.relationships[1].elements, ['comments', 'author']);
  });

  test('can encode query', () {
    expect(include.query, query);
  });
}
