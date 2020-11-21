import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/src/document/error_source.dart';
import 'package:test/test.dart';

void main() {
  group('ErrorObject', () {
    test('Minimal', () {
      expect(jsonEncode(ErrorObject()), '{}');
    });
    test('Full', () {
      expect(
          jsonEncode(ErrorObject(
              id: 'test_id',
              status: 'test_status',
              code: 'test_code',
              title: 'test_title',
              detail: 'test_detail',
              source: ErrorSource(
                  parameter: 'test_parameter', pointer: 'test_pointer'))
            ..links['foo'] = Link(Uri.parse('/bar'))
            ..meta['foo'] = 42),
          jsonEncode({
            'id': 'test_id',
            'status': 'test_status',
            'code': 'test_code',
            'title': 'test_title',
            'detail': 'test_detail',
            'source': {
              'parameter': 'test_parameter',
              'pointer': 'test_pointer'
            },
            'links': {'foo': '/bar'},
            'meta': {'foo': 42},
          }));
    });
  });
}
