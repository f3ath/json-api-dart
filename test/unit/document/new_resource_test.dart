import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
  group('NewResource', () {
    test('toResource throws on unmatched local id in "many"', () {
      final resource = NewResource('test_type', id: 'test_id', lid: 'test_lid')
        ..relationships['many'] = NewToMany([
          LocalIdentifier('test_type', 'test_lid2'),
        ]);

      expect(() => resource.toResource(() => 'my-test-id'), throwsStateError);
    });

    test('toResource throws on unmatched local id in "one"', () {
      final resource = NewResource('test_type', id: 'test_id', lid: 'test_lid')
        ..relationships['one'] =
            NewToOne(LocalIdentifier('test_type', 'test_lid2'));

      expect(() => resource.toResource(() => 'my-test-id'), throwsStateError);
    });

    test('toResource throws on invalid relationship', () {
      final resource = NewResource('test_type', id: 'test_id')
        ..relationships['many'] = NewRelationship();

      expect(() => resource.toResource(() => 'my-test-id'), throwsStateError);
    });

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
