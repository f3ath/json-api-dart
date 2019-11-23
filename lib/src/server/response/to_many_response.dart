import 'package:json_api/document.dart';
import 'package:json_api/src/server/response/response.dart';
import 'package:json_api/src/server/server_document_factory.dart';
import 'package:json_api/url_design.dart';

class ToManyResponse extends Response {
  final Iterable<Identifier> collection;
  final RelationshipTarget target;

  const ToManyResponse(this.target, this.collection) : super(200);

  @override
  Document<ToMany> buildDocument(ServerDocumentFactory builder, Uri self) =>
      builder.makeToManyDocument(collection, target: target, self: self);
}
