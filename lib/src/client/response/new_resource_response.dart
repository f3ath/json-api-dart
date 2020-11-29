import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/src/client/collection.dart';

/// A response to a new resource creation request.
class NewResourceResponse {
  NewResourceResponse(this.http, this.resource,
      {Map<String, Link> links = const {},
      Iterable<Resource> included = const []}) {
    this.included.addAll(included);
    this.links.addAll(links);
  }

  static NewResourceResponse decode(HttpResponse response) {
    final doc = InboundDocument.decode(response.body);
    return NewResourceResponse(response, doc.resource(),
        links: doc.links, included: doc.included);
  }

  /// Original HTTP response.
  final HttpResponse http;

  /// Created resource.
  final Resource resource;

  /// Included resources.
  final included = ResourceCollection();

  /// Document links.
  final links = <String, Link>{};
}
