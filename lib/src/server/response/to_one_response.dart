import 'package:json_api/document.dart';
import 'package:json_api/src/server/response/json_api_response.dart';
import 'package:json_api/src/server/server_document_factory.dart';
import 'package:json_api/src/url_design/url_design.dart';

class ToOneResponse extends ControllerResponse {
  final String type;
  final String id;
  final String relationship;
  final Identifier identifier;

  const ToOneResponse(this.type, this.id, this.relationship, this.identifier)
      : super(200);

  @override
  Document<ToOne> buildDocument(ServerDocumentFactory builder, Uri self) =>
      builder.makeToOneDocument(self, identifier, type, id, relationship);

  @override
  Map<String, String> buildHeaders(UrlFactory urlFactory) =>{
    'Content-Type': Document.contentType
  };
}
