import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
  test('type and id can not be null', () {
    expect(() => IdentifierObject(null, null), throwsArgumentError);
  });
}
