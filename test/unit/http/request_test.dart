import 'package:json_api/http.dart';
import 'package:test/test.dart';

void main() {
  test('HttpRequest converts method to lowercase', () {
    expect(HttpRequest('pAtCh', Uri()).method, 'patch');
  });

  test('HttpRequest converts headers keys to lowercase', () {
    expect(HttpRequest('post', Uri(), headers: {'FoO': 'Bar'}).headers,
        {'foo': 'Bar'});
  });
}
