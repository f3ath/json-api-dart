import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/src/document/document_exception.dart';
import 'package:test/test.dart';

void main() {
  test('link can encoded and decoded', () {
    final link = Link(Uri.parse('http://example.com'));
    expect(Link.fromJson(json.decode(json.encode(link))).uri.toString(),
        'http://example.com');
  });

  test('link object can be parsed from JSON', () {
    final link = Link(Uri.parse('http://example.com'), meta: {'foo': 'bar'});

    final parsed = Link.fromJson(json.decode(json.encode(link)));
    expect(parsed.uri.toString(), 'http://example.com');
    expect(parsed.meta['foo'], 'bar');
  });

  test('a map of link object can be parsed from JSON', () {
    final links = Link.mapFromJson({
      'first': 'http://example.com/first',
      'last': 'http://example.com/last'
    });
    expect(links['first'].uri.toString(), 'http://example.com/first');
    expect(links['last'].uri.toString(), 'http://example.com/last');
  });

  test('link throws DocumentException on invalid JSON', () {
    expect(() => Link.fromJson([]), throwsA(TypeMatcher<DocumentException>()));
    expect(
        () => Link.mapFromJson([]), throwsA(TypeMatcher<DocumentException>()));
  });
}
