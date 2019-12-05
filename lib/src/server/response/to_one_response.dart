import 'package:json_api/document.dart';
import 'package:json_api/src/server/response/response.dart';
import 'package:json_api/src/server/server_document_factory.dart';

class ToOneResponse extends Response {
  final String type;
  final String id;
  final String relationship;
  final Identifier identifier;

  const ToOneResponse(this.type, this.id, this.relationship, this.identifier)
      : super(200);

  @override
  Document<ToOne> buildDocument(ServerDocumentFactory builder, Uri self) =>
      builder.makeToOneDocument(self, identifier, type, id, relationship);
}
