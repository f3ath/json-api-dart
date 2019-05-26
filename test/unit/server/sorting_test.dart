import 'package:json_api/server.dart';
import 'package:test/test.dart';

void main() {
  test('can decode query', () {
    final uri = Uri.parse('/articles?sort=-created,title');
    final query = uri.queryParametersAll;
    final sorting = Sorting.fromQuery(query);

    expect(sorting.fields[0].name, 'created');
    expect(sorting.fields[0].ascending, false);
    expect(sorting.fields[0].descending, true);

    expect(sorting.fields[1].name, 'title');
    expect(sorting.fields[1].ascending, true);
    expect(sorting.fields[1].descending, false);
  });

  test('can encode query', () {
    final sorting =
        Sorting([SortField('foo'), SortField('bar', ascending: false)]);
    expect(sorting.query, {
      'sort': ['foo,-bar']
    });
  });
}
