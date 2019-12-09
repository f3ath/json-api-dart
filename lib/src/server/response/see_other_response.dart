import 'package:json_api/document.dart';
import 'package:json_api/src/server/response/response.dart';
import 'package:json_api/src/server/server_document_factory.dart';
import 'package:json_api/url_design.dart';

class SeeOtherResponse extends Response {
  final Resource resource;

  SeeOtherResponse(this.resource) : super(303);

  @override
  Document buildDocument(ServerDocumentFactory builder, Uri self) => null;

  @override
  Map<String, String> getHeaders(UrlFactory route) => {
        ...super.getHeaders(route),
        'Location': route.resource(resource.type, resource.id).toString()
      };
}
