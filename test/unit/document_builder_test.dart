import 'package:json_api/document.dart';
import 'package:json_api/src/document_builder.dart';
import 'package:test/test.dart';

void main() {
  test("api object is not included by default", () {
    final builder = DocumentBuilder();
    _expectDocumentsApi(null, builder);
  });

  test("if set, api obect will be included in all documents", () {
    final api = Api(version: "1.0");
    final builder = DocumentBuilder(api: api);
    _expectDocumentsApi(api, builder);
  });
}

void _expectDocumentsApi(Api api, DocumentBuilder builder) {
  final resource = Resource("apples", "1");
  expect(api, builder.errorDocument([]).api);
  expect(api, builder.collectionDocument([]).api);
  expect(api, builder.relatedCollectionDocument([]).api);
  expect(api, builder.makeResourceDocument(resource).api);
  expect(api, builder.relatedResourceDocument(resource).api);
  expect(api, builder.makeToManyDocument([]).api);
  expect(api, builder.makeToOneDocument(null).api);
  expect(api, builder.metaDocument({}).api);
}
