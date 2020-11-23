import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
  group('Resource', () {
    test('json encoding', () {
      expect(jsonEncode(Resource('test_type', 'test_id')),
          jsonEncode({'type': 'test_type', 'id': 'test_id'}));

      expect(
          jsonEncode(Resource('test_type', 'test_id')
            ..meta['foo'] = [42]
            ..attributes['color'] = 'green'
            ..relationships['one'] =
                (One(Identifier('rel', '1')..meta['rel'] = 1)..meta['one'] = 1)
            ..relationships['many'] =
                (Many([Identifier('rel', '1')..meta['rel'] = 1])
                  ..meta['many'] = 1)
            ..links['self'] = (Link(Uri.parse('/apples/42'))..meta['a'] = 1)),
          jsonEncode({
            'type': 'test_type',
            'id': 'test_id',
            'attributes': {'color': 'green'},
            'relationships': {
              'one': {
                'data': {
                  'type': 'rel',
                  'id': '1',
                  'meta': {'rel': 1}
                },
                'meta': {'one': 1}
              },
              'many': {
                'data': [
                  {
                    'type': 'rel',
                    'id': '1',
                    'meta': {'rel': 1}
                  },
                ],
                'meta': {'many': 1}
              }
            },
            'links': {
              'self': {
                'href': '/apples/42',
                'meta': {'a': 1}
              }
            },
            'meta': {
              'foo': [42]
            }
          }));
    });
    test('one() throws StateError when relationship does not exist', () {
      expect(() => Resource('books', '1').one('author'), throwsStateError);
    });
    test('many() throws StateError when relationship does not exist', () {
      expect(() => Resource('books', '1').many('tags'), throwsStateError);
    });
  });
}
