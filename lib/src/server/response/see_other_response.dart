import 'package:json_api/document.dart';
import 'package:json_api/src/server/response/json_api_response.dart';
import 'package:json_api/src/server/server_document_factory.dart';
import 'package:json_api/url_design.dart';

class SeeOtherResponse extends ControllerResponse {
  final String type;
  final String id;

  SeeOtherResponse(this.type, this.id) : super(303);

  @override
  Document buildDocument(ServerDocumentFactory builder, Uri self) => null;

  @override
  Map<String, String> buildHeaders(UrlFactory urlFactory) => {

        'Location': urlFactory.resource(type, id).toString()
      };
}
