import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
  final url = 'http://example.com';
  final json1 = {
    'href': url,
    'meta': {'foo': 'bar'}
  };
  final json2 = {'href': url};

  group('Link', () {
    test('can create from url', () {
      final link = Link(url);
      expect(link.href, url);
    });

    test('href can not be null', () {
      expect(() => Link(null), throwsArgumentError);
    });

    test('json conversion', () {
      expect(Link.fromJson(url).toJson(), url);
      expect(Link.fromJson(json1).toJson(), json1);
    });

    test('naming validation', () {
      expect(Link(url).validate(), []);
    });
  });

  group('LinkObject', () {
    test('can create from url and meta', () {
      final link = LinkObject(url, meta: {'foo': 'bar'});
      expect(link.href, url);
    });

    test('can create from url', () {
      final link = LinkObject(url);
      expect(link.href, url);
      expect(link.meta, isEmpty);
      expect(link.toJson(), {'href': url});
    });
    test('href can not be null', () {
      expect(() => LinkObject(null), throwsArgumentError);
    });

    test('json conversion', () {
      expect(LinkObject.fromJson(json1).toJson(), json1);
      expect(LinkObject.fromJson(json2).toJson(), json2);
    });

    test('naming validation', () {
      final violation =
          LinkObject(url, meta: {'_invalid': true}).validate().first;
      expect(violation.pointer, '/meta');
      expect(violation.value, '_invalid');
    });
  });
}
