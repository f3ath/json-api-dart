import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/src/client/response/fetch_response.dart';

class FetchRelatedResourceResponse extends FetchResponse {
  FetchRelatedResourceResponse(HttpResponse http, this.resource,
      {Iterable<Resource> included = const [],
      Map<String, Link> links = const {}})
      : super(http, included: included, links: links);

  static FetchRelatedResourceResponse decode(HttpResponse response) {
    final doc = InboundDocument.decode(response.body);
    return FetchRelatedResourceResponse(response, doc.nullableResource(),
        links: doc.links, included: doc.included);
  }

  /// Fetched resource
  final Resource? resource;
}
