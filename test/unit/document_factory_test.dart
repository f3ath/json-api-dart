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
  expect(builder.makeErrorDocument([]).api, api);
  expect(builder.makeCollectionDocument([]).api, api);
  expect(builder.makeRelatedCollectionDocument([]).api, api);
  expect(builder.makeResourceDocument(resource).api, api);
  expect(builder.makeRelatedResourceDocument(resource).api, api);
  expect(builder.makeToManyDocument([]).api, api);
  expect(builder.makeToOneDocument(null).api, api);
  expect(builder.makeMetaDocument({}).api, api);
}
