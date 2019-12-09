import 'package:json_api/document.dart';
import 'package:json_api/src/server/server_document_factory.dart';
import 'package:json_api/url_design.dart';

abstract class Response {
  final int status;

  const Response(this.status);

  Document buildDocument(ServerDocumentFactory factory, Uri self);

  Map<String, String> getHeaders(UrlFactory route) =>
      {'Content-Type': Document.contentType};
}
