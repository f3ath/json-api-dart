import 'package:json_api/document.dart';
import 'package:json_api/src/server/response/json_api_response.dart';
import 'package:json_api/src/server/server_document_factory.dart';
import 'package:json_api/url_design.dart';

class SeeOtherResponse extends JsonApiResponse {
  final Resource resource;

  SeeOtherResponse(this.resource) : super(303);

  @override
  Document buildDocument(ServerDocumentFactory builder, Uri self) => null;

  @override
  Map<String, String> getHeaders(UrlFactory urlFactory) => {
        ...super.getHeaders(urlFactory),
        'Location': urlFactory.resource(resource.type, resource.id).toString()
      };
}
