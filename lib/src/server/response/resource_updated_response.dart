import 'package:json_api/document.dart';
import 'package:json_api/src/server/response/json_api_response.dart';
import 'package:json_api/src/server/server_document_factory.dart';
import 'package:json_api/src/url_design/url_design.dart';

class ResourceUpdatedResponse extends ControllerResponse {
  final Resource resource;

  ResourceUpdatedResponse(this.resource) : super(200);

  @override
  Document<ResourceData> buildDocument(
          ServerDocumentFactory builder, Uri self) =>
      builder.makeResourceDocument(self, resource);

  @override
  Map<String, String> buildHeaders(UrlFactory urlFactory) => {
    'Content-Type': Document.contentType
  };
}
