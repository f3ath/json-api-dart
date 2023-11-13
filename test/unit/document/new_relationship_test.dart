import 'package:json_api/document.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('NewRelationship', () {
    test('iterator', () {
      final list = [];
      list.addAll(NewRelationship());
      expect(list, isEmpty);
    });
  });
}
