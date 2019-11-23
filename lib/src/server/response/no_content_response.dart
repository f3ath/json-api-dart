import 'package:json_api/document.dart';
import 'package:json_api/src/server/response/response.dart';
import 'package:json_api/src/server/server_document_factory.dart';

class NoContentResponse extends Response {
  const NoContentResponse() : super(204);

  @override
  Document<PrimaryData> buildDocument(
          ServerDocumentFactory factory, Uri self) =>
      null;
}
