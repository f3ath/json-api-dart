import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
  test('equal identifiers are detected by Set', () {
    expect({Identifiers('foo', '1'), Identifiers('foo', '1')}.length, 1);
  });
}
