import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
  group('custom links', () {
    test('recognizes custom links', () {
      final e = JsonApiError(
          links: {'my-link': Link(Uri.parse('http://example.com'))});
      expect(e.links['my-link'].toString(), 'http://example.com');
    });

    test('if passed, "about" argument is merged into "links"', () {
      final e = JsonApiError(
          about: Link(Uri.parse('/about')),
          links: {'my-link': Link(Uri.parse('http://example.com'))});
      expect(e.links['my-link'].toString(), 'http://example.com');
      expect(e.links['about'].toString(), '/about');
      expect(e.about.toString(), '/about');
    });

    test('"links" may contain the "about" key', () {
      final e = JsonApiError(links: {
        'my-link': Link(Uri.parse('http://example.com')),
        'about': Link(Uri.parse('/about'))
      });
      expect(e.links['my-link'].toString(), 'http://example.com');
      expect(e.links['about'].toString(), '/about');
      expect(e.about.toString(), '/about');
    });

    test('"about" argument  takes precedence over "links"', () {
      final e = JsonApiError(
          about: Link(Uri.parse('/about')),
          links: {'about': Link(Uri.parse('/will-be-replaced'))});
      expect(e.links['about'].toString(), '/about');
    });

    test('custom "links" survives json serialization', () {
      final e = JsonApiError(
          links: {'my-link': Link(Uri.parse('http://example.com'))});
      expect(
          JsonApiError.fromJson(json.decode(json.encode(e)))
              .links['my-link']
              .toString(),
          'http://example.com');
    });
  });
}
