import 'package:json_api/document.dart';
import 'package:json_matcher/json_matcher.dart';
import 'package:test/test.dart';

void main() {
  group('Document', () {
    group('JSON Conversion', () {
      test('Can convert a single resource', () {
        final doc = Document(ResourceData(ResourceObject('foo', 'bar')));

        expect(
            doc,
            encodesToJson({
              'data': {'type': 'foo', 'id': 'bar'}
            }));
      });
    });
  });
}
