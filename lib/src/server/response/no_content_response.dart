import 'package:json_api/document.dart';
import 'package:json_api/src/server/response/json_api_response.dart';
import 'package:json_api/src/server/server_document_factory.dart';
import 'package:json_api/url_design.dart';

class NoContentResponse extends ControllerResponse {
  final Map<String, String> headers;

  const NoContentResponse({this.headers = const {}}) : super(204);

  @override
  Document<PrimaryData> buildDocument(
          ServerDocumentFactory factory, Uri self) =>
      null;

  @override
  Map<String, String> buildHeaders(UrlFactory urlFactory) => headers;
}
