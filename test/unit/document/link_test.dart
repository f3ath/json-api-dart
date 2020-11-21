import 'dart:convert';
import 'dart:io';

import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
  group('Link', () {
    final href = 'http://example.com';
    test('String', () {
      expect(jsonEncode(Link(Uri.parse(href))), jsonEncode(href));
    });
    test('Object', () {
      expect(
          jsonEncode(Link(Uri.parse(href))..meta['foo'] = []),
          jsonEncode({
            'href': href,
            'meta': {'foo': []}
          }));
    });
  });
}
