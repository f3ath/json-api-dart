import 'package:json_api/src/server/_server.dart';
import 'package:test/test.dart';

void main() {
  test('can decode query', () {
    final uri = Uri.parse('/articles?page[limit]=10&page[offset]=30&foo=bar');
    final query = uri.queryParametersAll;
    final page = PageParameters.fromQuery(query);

    expect(page.parameters.length, 2);
    expect(page.parameters['limit'], '10');
    expect(page.parameters['offset'], '30');
  });

  test('can encode query', () {
    final page = PageParameters({'limit': '10', 'offset': '30'});
    expect(page.query, {
      'page[limit]': ['10'],
      'page[offset]': ['30']
    });
  });
}
