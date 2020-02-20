import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
  test('equal identifiers are detected by Set', () {
    expect({Identifier('foo', '1'), Identifier('foo', '1')}.length, 1);
  });
}
