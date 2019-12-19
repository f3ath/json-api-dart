import 'package:json_api/document.dart';
import 'package:json_api/src/server/server_document_factory.dart';
import 'package:json_api/url_design.dart';

abstract class JsonApiResponse {
  final int status;

  const JsonApiResponse(this.status);

  Document buildDocument(ServerDocumentFactory factory, Uri self);

  Map<String, String> getHeaders(UrlFactory urlFactory) =>
      {'Content-Type': Document.contentType};
}
