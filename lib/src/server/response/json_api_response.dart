import 'package:json_api/document.dart';
import 'package:json_api/src/server/server_document_factory.dart';
import 'package:json_api/url_design.dart';

abstract class ControllerResponse {
  final int statusCode;

  const ControllerResponse(this.statusCode);

  Document buildDocument(ServerDocumentFactory factory, Uri self);

  Map<String, String> buildHeaders(UrlFactory urlFactory) =>
      {'Content-Type': Document.contentType};
}
