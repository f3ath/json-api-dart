@TestOn('vm')
import 'dart:convert';
import 'dart:io';

import 'package:json_api/parser.dart';
import 'package:json_matcher/json_matcher.dart';
import 'package:test/test.dart';

void main() {
  final parser = JsonApiParser();
  group('Parser', () {
    try {
      test('Can parse the example document', () {
        // This is a slightly modified example from the JSON:API site
        // See: https://jsonapi.org/
        final jsonString =
            new File('test/unit/example.json').readAsStringSync();
        final jsonObject = json.decode(jsonString);
        final doc = parser.parseDocument(
            jsonObject, parser.parseResourceCollectionData);

        expect(doc, encodesToJson(jsonObject));
      });
    } catch (e, s) {
      print(s);
    }
  });
}
