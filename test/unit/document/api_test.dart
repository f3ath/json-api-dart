import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/src/document/document_exception.dart';
import 'package:json_matcher/json_matcher.dart';
import 'package:test/test.dart';

void main() {
  test('Api can be json-encoded', () {
    final api =
        Api.fromJson(json.decode(json.encode(Api()..meta['foo'] = 'bar')));
    expect('1.0', api.version);
    expect('bar', api.meta['foo']);
  });

  test('Throws exception when can not be decoded', () {
    expect(() => Api.fromJson([]), throwsA(TypeMatcher<DocumentException>()));
  });

  test('Empty/null properties are not encoded', () {
    expect(Api(), encodesToJson({}));
  });
}
