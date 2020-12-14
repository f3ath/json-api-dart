import 'package:json_api/document.dart';
import 'package:json_api/http.dart';

/// A response to a new resource creation request.
/// This is always a "201 Created" response.
///
/// https://jsonapi.org/format/#crud-creating-responses-201
class ResourceCreated {
  ResourceCreated(this.http, Map json)
      : resource = InboundDocument(json).dataAsResource() {
    links.addAll(InboundDocument(json).links());
    included.addAll(InboundDocument(json).included());
  }

  final HttpResponse http;

  /// Created resource.
  final Resource resource;
  final links = <String, Link>{};

  /// Included resources
  final included = ResourceCollection();
}
