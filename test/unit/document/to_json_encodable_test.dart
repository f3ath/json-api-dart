import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
  group('toJsonEncodable()', () {
    test('throws UnsupportedError', () {
      expect(() => toJsonEncodable('wow'), throwsUnsupportedError);
    });
  });
}
