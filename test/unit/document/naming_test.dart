import 'package:json_api/src/validation/_validation.dart';
import 'package:test/test.dart';

void main() {
  const naming = const StandardNaming();
  final expectNotToBeAllowed =
      (String name) => expect(naming.allows(name), equals(false));
  final expectToBeAllowed =
      (String name) => expect(naming.allows(name), equals(true));

  test('Empty strings are not allowed', () {
    expect(naming.allows(''), equals(false));
  });
  test('Chars with codes 0x0080 and above are allowed', () {
    expect(naming.allows('щачло'), equals(true));
  });
  test('"-" is not allowed as first and last char', () {
    ['-', '-abc', 'abc-'].forEach(expectNotToBeAllowed);
  });
  test('"_" is not allowed as first and last char', () {
    ['_', '_abc', 'abc_'].forEach(expectNotToBeAllowed);
  });
  test('Space is not allowed as first and last char', () {
    [' ', ' abc', 'abc '].forEach(expectNotToBeAllowed);
  });
  test('Space is allowed inside strings', () {
    expect(naming.allows('жа жа'), equals(true));
  });
  test('Alphanumeric chars are allowed anywhere', () {
    ['a', 'fooBar42', '123'].forEach(expectToBeAllowed);
  });
  test('"-" and "_" are allowed inside', () {
    ['o-o', 'O_O', 'o-_-o'].forEach(expectToBeAllowed);
  });
}
