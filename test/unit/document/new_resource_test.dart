import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
  group('NewResource', () {
    test('json encoding', () {
      expect(jsonEncode(NewResource('test_type')),
          jsonEncode({'type': 'test_type'}));

      expect(
          jsonEncode(NewResource('test_type')
            ..meta['foo'] = [42]
            ..attributes['color'] = 'green'
            ..relationships['one'] =
                (ToOne(Identifier('rel', '1')..meta['rel'] = 1)
                  ..meta['one'] = 1)
            ..relationships['many'] =
                (ToMany([Identifier('rel', '1')..meta['rel'] = 1])
                  ..meta['many'] = 1)),
          jsonEncode({
            'type': 'test_type',
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
            'meta': {
              'foo': [42]
            }
          }));
    });
  });
}
