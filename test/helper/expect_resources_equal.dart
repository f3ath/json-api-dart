import 'package:json_api/document.dart';
import 'package:test/test.dart';

void expectResourcesEqual(Resource a, Resource b) {
  expect(a.type, equals(b.type));
  expect(a.id, equals(b.id));
  expect(a.attributes, equals(b.attributes));
  expect(a.toOne, equals(b.toOne));
  expect(a.toMany, equals(b.toMany));
}
