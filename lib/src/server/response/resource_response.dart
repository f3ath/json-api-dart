import 'package:json_api/document.dart';
import 'package:json_api/src/server/response/response.dart';
import 'package:json_api/src/server/server_document_factory.dart';

class ResourceResponse extends Response {
  final Resource resource;
  final Iterable<Resource> included;

  const ResourceResponse(this.resource, {this.included = const []})
      : super(200);

  @override
  Document<ResourceData> buildDocument(
          ServerDocumentFactory builder, Uri self) =>
      builder.makeResourceDocument(resource, self: self, included: included);
}
