import 'package:json_api/core.dart';
import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
  final a = Identifier(Ref('apples', 'a'));
  final b = Identifier(Ref('apples', 'b'));
  group('Relationship', () {
    test('one', () {
      expect(ToOne(a).identifier, a);
      expect([...ToOne(a)].first, a);

      expect(ToOne.empty().identifier, isNull);
      expect([...ToOne.empty()], isEmpty);
    });

    test('many', () {
      expect(ToMany([]), isEmpty);
      expect([...ToMany([])], isEmpty);

      expect(ToMany([a]), isNotEmpty);
      expect(
          [
            ...ToMany([a])
          ].first,
          a);

      expect(ToMany([a, b]), isNotEmpty);
      expect(
          [
            ...ToMany([a, b])
          ].first,
          a);
      expect(
          [
            ...ToMany([a, b])
          ].last,
          b);
    });
  });

  test('incomplete', () {
    expect(Relationship(), isEmpty);
    expect([...Relationship()], isEmpty);
  });
}
