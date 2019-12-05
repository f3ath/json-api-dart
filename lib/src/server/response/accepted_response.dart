import 'package:json_api/document.dart';
import 'package:json_api/src/server/response/response.dart';
import 'package:json_api/src/server/server_document_factory.dart';
import 'package:json_api/url_design.dart';

class AcceptedResponse extends Response {
  final Resource resource;

  AcceptedResponse(this.resource) : super(202);

  @override
  Document<ResourceData> buildDocument(
          ServerDocumentFactory factory, Uri self) =>
      factory.makeResourceDocument(self, resource);

  @override
  Map<String, String> getHeaders(UrlFactory route) => {
        ...super.getHeaders(route),
        'Content-Location':
            route.resource(resource.type, resource.id).toString(),
      };
}
