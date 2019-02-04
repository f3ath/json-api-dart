import 'package:json_api/document.dart';
import 'package:json_matcher/json_matcher.dart';
import 'package:test/test.dart';

void main() {
  test('ToOne can be empty', () {
    expect(ToOne(null), encodesToJson({'data': null}));
  });
}
