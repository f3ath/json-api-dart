import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
  test('Can decode a primary resource with missing id', () {
    final data = ResourceData.fromJson(json.decode(json.encode({
      'data': {'type': 'apples'}
    })));
    expect(data.unwrap().type, 'apples');
    expect(data.unwrap().id, isNull);
  });

  test('Can decode a primary resource with null id', () {
    final data = ResourceData.fromJson(json.decode(json.encode({
      'data': {'type': 'apples', 'id': null}
    })));
    expect(data.unwrap().type, 'apples');
    expect(data.unwrap().id, isNull);
  });

  test('Inherits links from ResourceObject', () {
    final res = ResourceObject('apples', '1',
        self: Link(Uri.parse('/self')),
        links: {
          'foo': Link(Uri.parse('/foo')),
          'bar': Link(Uri.parse('/bar'))
        });
    final data = ResourceData(res, links: {
      'bar': Link(Uri.parse('/bar-new')),
    });
    expect(data.links['foo'].toString(), '/foo');
    expect(data.links['bar'].toString(), '/bar-new');
    expect(data.self.toString(), '/self');
  });

  group('custom links', () {
    final res = ResourceObject('apples', '1');
    test('recognizes custom links', () {
      final data =
          ResourceData(res, links: {'my-link': Link(Uri.parse('/my-link'))});
      expect(data.links['my-link'].toString(), '/my-link');
    });

    test('if passed, "self" argument is merged into "links"', () {
      final data = ResourceData(res,
          self: Link(Uri.parse('/self')),
          links: {'my-link': Link(Uri.parse('/my-link'))});
      expect(data.links['my-link'].toString(), '/my-link');
      expect(data.links['self'].toString(), '/self');
      expect(data.self.toString(), '/self');
    });

    test('"links" may contain the "self" key', () {
      final data = ResourceData(res, links: {
        'my-link': Link(Uri.parse('/my-link')),
        'self': Link(Uri.parse('/self'))
      });
      expect(data.links['my-link'].toString(), '/my-link');
      expect(data.links['self'].toString(), '/self');
      expect(data.self.toString(), '/self');
    });

    test('"self" takes precedence over "links"', () {
      final data = ResourceData(res, self: Link(Uri.parse('/self')), links: {
        'my-link': Link(Uri.parse('/my-link')),
        'self': Link(Uri.parse('/will-be-replaced'))
      });
      expect(data.links['my-link'].toString(), '/my-link');
      expect(data.links['self'].toString(), '/self');
      expect(data.self.toString(), '/self');
    });

    test('survives json serialization', () {
      final data = ResourceData(res, links: {
        'my-link': Link(Uri.parse('/my-link')),
      });
      expect(
          ResourceData.fromJson(json.decode(json.encode(data)))
              .links['my-link']
              .toString(),
          '/my-link');
    });
  });
}
