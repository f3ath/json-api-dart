import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
  group('links', () {
    test('recognizes custom links', () {
      final e = ErrorObject(
          links: {'my-link': Link(Uri.parse('http://example.com'))});
      expect(e.links['my-link'].toString(), 'http://example.com');
    });

    test('"links" may contain the "about" key', () {
      final e = ErrorObject(links: {
        'my-link': Link(Uri.parse('http://example.com')),
        'about': Link(Uri.parse('/about'))
      });
      expect(e.links['my-link'].toString(), 'http://example.com');
      expect(e.links['about'].toString(), '/about');
      expect(e.links['about'].toString(), '/about');
    });

    test('custom "links" survives json serialization', () {
      final e = ErrorObject(
          links: {'my-link': Link(Uri.parse('http://example.com'))});
      expect(
          ErrorObject.fromJson(json.decode(json.encode(e)))
              .links['my-link']
              .toString(),
          'http://example.com');
    });
  });
}
