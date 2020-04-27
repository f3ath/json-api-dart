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

  test('Can decode a related resource which is null', () {
    final data =
        ResourceData.fromJson(json.decode(json.encode({'data': null})));
    expect(data.unwrap(), null);
  });

  group('custom links', () {
    final res = ResourceObject('apples', '1');
    test('recognizes custom links', () {
      final data =
          ResourceData(res, links: {'my-link': Link(Uri.parse('/my-link'))});
      expect(data.links['my-link'].toString(), '/my-link');
    });

    test('"links" may contain the "self" key', () {
      final data = ResourceData(res, links: {
        'my-link': Link(Uri.parse('/my-link')),
        'self': Link(Uri.parse('/self'))
      });
      expect(data.links['my-link'].toString(), '/my-link');
      expect(data.links['self'].toString(), '/self');
      expect(data.links['self'].toString(), '/self');
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
