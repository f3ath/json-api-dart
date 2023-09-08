import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
  group('NewResource', () {
    test('json encoding', () {
      expect(jsonEncode(NewResource('test_type')),
          jsonEncode({'type': 'test_type'}));

      expect(
          jsonEncode(NewResource('test_type', id: 'test_id', lid: 'test_lid')
            ..meta['foo'] = [42]
            ..attributes['color'] = 'green'
            ..relationships['one'] =
                (NewToOne(Identifier('rel', '1')..meta['rel'] = 1)
                  ..meta['one'] = 1)
            ..relationships['self'] = (NewToOne(
                LocalIdentifier('test_type', 'test_lid')..meta['rel'] = 1)
              ..meta['one'] = 1)
            ..relationships['many'] = (NewToMany([
              Identifier('rel', '1')..meta['rel'] = 1,
              LocalIdentifier('test_type', 'test_lid')..meta['rel'] = 1,
            ])
              ..meta['many'] = 1)),
          jsonEncode({
            'type': 'test_type',
            'id': 'test_id',
            'lid': 'test_lid',
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
              'self': {
                'data': {
                  'type': 'test_type',
                  'lid': 'test_lid',
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
                  {
                    'type': 'test_type',
                    'lid': 'test_lid',
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
