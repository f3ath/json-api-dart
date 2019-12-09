import 'package:json_api/document.dart';
import 'package:json_api/src/server/response/response.dart';
import 'package:json_api/src/server/server_document_factory.dart';

class RelatedCollectionResponse extends Response {
  final Iterable<Resource> collection;
  final Iterable<Resource> included;
  final int total;

  const RelatedCollectionResponse(this.collection,
      {this.included = const [], this.total})
      : super(200);

  @override
  Document<ResourceCollectionData> buildDocument(
          ServerDocumentFactory builder, Uri self) =>
      builder.makeRelatedCollectionDocument(self, collection, total: total);
}
