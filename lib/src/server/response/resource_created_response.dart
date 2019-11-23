import 'package:json_api/document.dart';
import 'package:json_api/src/server/response/response.dart';
import 'package:json_api/src/server/server_document_factory.dart';
import 'package:json_api/url_design.dart';

class ResourceCreatedResponse extends Response {
  final Resource resource;

  ResourceCreatedResponse(this.resource) : super(201);

  @override
  Document<ResourceData> buildDocument(
          ServerDocumentFactory builder, Uri self) =>
      builder.makeResourceDocument(resource, self: self);

  @override
  Map<String, String> getHeaders(UrlFactory route) => {
        ...super.getHeaders(route),
        'Location': route.resource(resource.type, resource.id).toString()
      };
}
