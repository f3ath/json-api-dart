import 'package:json_api/document.dart';
import 'package:json_api/src/server/response/json_api_response.dart';
import 'package:json_api/src/server/server_document_factory.dart';

class ResourceResponse extends JsonApiResponse {
  final Resource resource;
  final Iterable<Resource> included;

  const ResourceResponse(this.resource, {this.included}) : super(200);

  @override
  Document<ResourceData> buildDocument(
          ServerDocumentFactory builder, Uri self) =>
      builder.makeResourceDocument(self, resource, included: included);
}
