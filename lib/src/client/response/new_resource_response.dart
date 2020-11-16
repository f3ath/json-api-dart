import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/src/client/identity_collection.dart';

class NewResourceResponse {
  NewResourceResponse(this.http, this.resource,
      {Map<String, Link> links = const {},
      Iterable<Resource> included = const []})
      : included = IdentityCollection(included) {
    this.links.addAll(links);
  }

  static NewResourceResponse decode(HttpResponse response) {
    final doc = InboundDocument.decode(response.body);
    return NewResourceResponse(response, doc.resource(),
        links: doc.links, included: doc.included);
  }

  /// Original HTTP response
  final HttpResponse http;

  final Resource /*?*/ resource;
  final IdentityCollection<Resource> included;
  final links = <String, Link>{};
}
