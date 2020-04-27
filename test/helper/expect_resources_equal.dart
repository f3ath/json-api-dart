import 'package:json_api/document.dart';
import 'package:test/test.dart';

void expectResourcesEqual(Resource a, Resource b) {
  expect(a.type, equals(b.type));
  expect(a.id, equals(b.id));
  expect(a.attributes, equals(b.attributes));
  expect(a.toOne.keys, equals(b.toOne.keys));
  expect(a.toOne.values.map((_) => _.mapIfExists((_) => _, () => null)),
      equals(b.toOne.values.map((_) => _.mapIfExists((_) => _, () => null))));
  expect(a.toMany.keys, equals(b.toMany.keys));
  expect(a.toMany.values.expand((_) => _.toList()),
      equals(b.toMany.values.expand((_) => _.toList())));
}
