import 'package:json_api/http.dart';
import 'package:test/test.dart';

void main() {
  group('Headers', () {
    test('add, read, clear', () {
      final h = Headers({'Foo': 'Bar'});
      expect(h['Foo'], 'Bar');
      expect(h['foo'], 'Bar');
      expect(h['fOO'], 'Bar');
      expect(h.length, 1);
      h['FOO'] = 'Baz';
      expect(h['Foo'], 'Baz');
      expect(h['foo'], 'Baz');
      expect(h['fOO'], 'Baz');
      expect(h.length, 1);
      h['hello'] = 'world';
      expect(h.length, 2);
      h.remove('foo');
      expect(h['foo'], isNull);
      expect(h.length, 1);
      h.clear();
      expect(h.length, 0);
      expect(h.isEmpty, true);
      expect(h.isNotEmpty, false);
    });
  });
}
