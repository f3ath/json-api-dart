import 'package:json_api/document.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('NewToOne', () {
    test('can be iterated', () {
      final id = Identifier('books', '123');
      final r = NewToOne(id);
      final list = <NewIdentifier>[];
      list.addAll(r);
      expect(list.single, equals(id));
    });
  });
}
