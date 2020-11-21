import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
  final a = Identifier('apples', 'a');
  final b = Identifier('apples', 'b');
  group('Relationship', () {
    test('one', () {
      expect(One(a).identifier, a);
      expect([...One(a)].first, a);

      expect(One.empty().identifier, isNull);
      expect([...One.empty()], isEmpty);
    });

    test('many', () {
      expect(Many([]), isEmpty);
      expect([...Many([])], isEmpty);

      expect(Many([a]), isNotEmpty);
      expect(
          [
            ...Many([a])
          ].first,
          a);

      expect(Many([a, b]), isNotEmpty);
      expect(
          [
            ...Many([a, b])
          ].first,
          a);
      expect(
          [
            ...Many([a, b])
          ].last,
          b);
    });
  });

  test('incomplete', () {
    expect(Relationship(), isEmpty);
    expect([...Relationship()], isEmpty);
  });
}
