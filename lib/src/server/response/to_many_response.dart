import 'package:json_api/document.dart';
import 'package:json_api/src/server/response/json_api_response.dart';
import 'package:json_api/src/server/server_document_factory.dart';
import 'package:json_api/src/url_design/url_design.dart';

class ToManyResponse extends ControllerResponse {
  final Iterable<Identifier> collection;
  final String type;
  final String id;
  final String relationship;

  const ToManyResponse(this.type, this.id, this.relationship, this.collection)
      : super(200);

  @override
  Document<ToMany> buildDocument(ServerDocumentFactory builder, Uri self) =>
      builder.makeToManyDocument(self, collection, type, id, relationship);

  @override
  Map<String, String> buildHeaders(UrlFactory urlFactory) =>{
    'Content-Type': Document.contentType
  };
}
