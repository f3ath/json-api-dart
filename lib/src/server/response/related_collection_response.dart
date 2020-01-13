import 'package:json_api/document.dart';
import 'package:json_api/src/server/response/json_api_response.dart';
import 'package:json_api/src/server/server_document_factory.dart';
import 'package:json_api/src/url_design/url_design.dart';

class RelatedCollectionResponse extends ControllerResponse {
  final Iterable<Resource> collection;
  final Iterable<Resource> included;
  final int total;

  const RelatedCollectionResponse(this.collection, {this.included, this.total})
      : super(200);

  @override
  Document<ResourceCollectionData> buildDocument(
          ServerDocumentFactory builder, Uri self) =>
      builder.makeRelatedCollectionDocument(self, collection, total: total);

  @override
  Map<String, String> buildHeaders(UrlFactory urlFactory) =>{
    'Content-Type': Document.contentType
  };
}
