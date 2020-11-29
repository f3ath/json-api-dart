import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/src/client/collection.dart';
import 'package:json_api/src/client/response/fetch_response.dart';

class FetchCollectionResponse extends FetchResponse {
  FetchCollectionResponse(HttpResponse http, Iterable<Resource> collection,
      {Iterable<Resource> included = const [],
      Map<String, Link> links = const {}})
      : super(http, included: included, links: links) {
    this.collection.addAll(collection);
  }

  static FetchCollectionResponse decode(HttpResponse response) {
    final doc = InboundDocument.decode(response.body);
    return FetchCollectionResponse(response, doc.resourceCollection(),
        links: doc.links, included: doc.included);
  }

  /// Fetched collection
  final collection = ResourceCollection();
}
