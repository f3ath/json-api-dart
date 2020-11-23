import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/src/client/identity_collection.dart';

class ResourceResponse {
  ResourceResponse(this.http, this.resource,
      {Map<String, Link> links = const {},
      Iterable<Resource> included = const []})
      : included = IdentityCollection(included) {
    this.links.addAll(links);
  }

  ResourceResponse.noContent(this.http)
      : resource = null,
        included = IdentityCollection(const []);

  static ResourceResponse decode(HttpResponse response) {
    if (response.isNoContent) return ResourceResponse.noContent(response);
    final doc = InboundDocument.decode(response.body);
    return ResourceResponse(response, doc.nullableResource(),
        links: doc.links, included: doc.included);
  }

  /// Original HTTP response
  final HttpResponse http;

  /// The created resource. Null for "204 No Content" responses.
  final Resource /*?*/ resource;

  /// Included resources
  final IdentityCollection<Resource> included;

  /// Document links
  final links = <String, Link>{};
}
