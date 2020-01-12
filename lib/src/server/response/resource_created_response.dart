import 'package:json_api/document.dart';
import 'package:json_api/src/server/response/json_api_response.dart';
import 'package:json_api/src/server/server_document_factory.dart';
import 'package:json_api/url_design.dart';

class ResourceCreatedResponse extends ControllerResponse {
  final Resource resource;

  ResourceCreatedResponse(this.resource) : super(201) {
    ArgumentError.checkNotNull(resource.id, 'resource.id');
  }

  @override
  Document<ResourceData> buildDocument(
          ServerDocumentFactory builder, Uri self) =>
      builder.makeCreatedResourceDocument(resource);

  @override
  Map<String, String> buildHeaders(UrlFactory urlFactory) => {
        ...super.buildHeaders(urlFactory),
        'Location': urlFactory.resource(resource.type, resource.id).toString()
      };
}
