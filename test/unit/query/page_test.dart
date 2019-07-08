import 'package:json_api/query.dart';
import 'package:test/test.dart';

void main() {
  test('Can decode url', () {
    final uri = Uri.parse('/articles?page[limit]=10&page[offset]=20');
    final page = Page.decode(uri.queryParametersAll);
    expect(page['limit'], '10');
    expect(page['offset'], '20');
  });

  test('Can add to uri', () {
    final fields = Page({'limit': '10', 'offset': '20'});
    final uri = Uri.parse('/articles');

    expect(fields.addTo(uri).toString(),
        '/articles?page%5Blimit%5D=10&page%5Boffset%5D=20');
  });
}
