import 'package:json_api/query.dart';
import 'package:test/test.dart';

void main() {
  test('parameters can be merged', () {
    final params = Fields({
          'comments': ['author']
        }) &
        Include(['author']) &
        Page({'limit': '10'});
    expect(params.addToUri(Uri()).query,
        'fields%5Bcomments%5D=author&include=author&page%5Blimit%5D=10');
  });
}
