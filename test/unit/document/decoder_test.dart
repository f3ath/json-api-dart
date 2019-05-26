import 'dart:convert';
import 'dart:io';

import 'package:json_api/document.dart';
import 'package:json_api/src/document/document_decoder.dart';
import 'package:json_matcher/json_matcher.dart';
import 'package:test/test.dart';

import 'helper.dart';

void main() {
  final decoder = JsonApiDecoder();
  group('Decoder', () {
    test('Can decode the example document', () {
      // This is a slightly modified example from the JSON:API site
      // See: https://jsonapi.org/
      final jsonString =
          new File('test/unit/document/example.json').readAsStringSync();
      final jsonObject = json.decode(jsonString);
      final doc = decoder.decodeDocument(
          jsonObject, decoder.decodeResourceCollectionData);

      expect(doc, encodesToJson(jsonObject));
    }, testOn: 'vm');

    test('Can parse a primary resource with missing id', () {
      final doc = decoder.decodeResourceDocument(recodeJson({
        'data': {'type': 'apples'}
      }));
      expect(doc.data.toResource().type, 'apples');
      expect(doc.data.toResource().id, isNull);
    });

    test('Can parse a primary resource with null id', () {
      final doc = decoder.decodeResourceDocument(recodeJson({
        'data': {'type': 'apples', 'id': null}
      }));
      expect(doc.data.toResource().type, 'apples');
      expect(doc.data.toResource().id, isNull);
    });

    test('Can parse LinkObject', () {
      final link1 = decoder.decodeLink({'href': '/foo'});
      expect(link1, TypeMatcher<LinkObject>());
      expect(link1.uri.toString(), '/foo');

      final link2 = decoder.decodeLink({
        'href': '/foo',
        'meta': {'foo': 'bar'}
      });
      expect(link2, TypeMatcher<LinkObject>());
      expect((link2 as LinkObject).meta['foo'], 'bar');
    });
  });
}
