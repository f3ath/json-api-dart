import 'dart:convert';
import 'dart:io';

@TestOn('vm')
import 'package:json_api/document.dart';
import 'package:json_matcher/json_matcher.dart';
import 'package:test/test.dart';

void main() {
  group('Document', () {
    group('JSON Conversion', () {
      test('Can convert a single resource', () {
        final doc = Document(ResourceData(ResourceJson('foo', 'bar')));

        expect(
            doc,
            encodesToJson({
              'data': {'type': 'foo', 'id': 'bar'}
            }));
      });
    });

    group('Standard compliance', () {
      try {
        test('Can parse the example document', () {
          // This is a slightly modified example from the JSON:API site
          // See: https://jsonapi.org/
          final jsonString =
              new File('test/unit/example.json').readAsStringSync();
          final jsonObject = json.decode(jsonString);
          final doc = Document.parse(jsonObject, ResourceCollectionData.parse);

          expect(doc, encodesToJson(jsonObject));
        });
      } catch (e, s) {
        print(s);
      }
    });
  });
}
