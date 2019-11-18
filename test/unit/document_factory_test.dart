import 'package:json_api/document.dart';
import 'package:json_api/src/document_factory.dart';
import 'package:test/test.dart';

void main() {
  test("api object is not included by default", () {
    final builder = DocumentFactory();
    _expectDocumentsApi(null, builder);
  });

  test("if set, api obect will be included in all documents", () {
    final api = Api(version: "1.0");
    final builder = DocumentFactory(api: api);
    _expectDocumentsApi(api, builder);
  });
}

void _expectDocumentsApi(Api api, DocumentFactory builder) {
  final resource = Resource("apples", "1");
  expect(api, builder.makeErrorDocument([]).api);
  expect(api, builder.makeCollectionDocument([]).api);
  expect(api, builder.makeRelatedCollectionDocument([]).api);
  expect(api, builder.makeResourceDocument(resource).api);
  expect(api, builder.makeRelatedResourceDocument(resource).api);
  expect(api, builder.makeToManyDocument([]).api);
  expect(api, builder.makeToOneDocument(null).api);
  expect(api, builder.makeMetaDocument({}).api);
}
