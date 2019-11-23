import 'package:json_api/document.dart';
import 'package:json_api/src/server/response/response.dart';
import 'package:json_api/src/server/server_document_factory.dart';
import 'package:json_api/url_design.dart';

class ToOneResponse extends Response {
  final Identifier identifier;
  final RelationshipTarget target;

  const ToOneResponse(this.target, this.identifier) : super(200);

  @override
  Document<ToOne> buildDocument(ServerDocumentFactory builder, Uri self) =>
      builder.makeToOneDocument(identifier, target: target, self: self);
}
