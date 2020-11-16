import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/src/client/identity_collection.dart';

/// A response to a fetch collection request.
///
/// See https://jsonapi.org/format/#fetching-resources-responses
class CollectionResponse {
  CollectionResponse(this.http,
      {Iterable<Resource> collection = const [],
      Iterable<Resource> included = const [],
      Map<String, Link> links = const {}})
      : collection = IdentityCollection(collection),
        included = IdentityCollection(included) {
    this.links.addAll(links);
  }

  static CollectionResponse decode(HttpResponse response) {
    final doc = InboundDocument.decode(response.body);
    return CollectionResponse(response,
        collection: doc.resourceCollection(),
        included: doc.included,
        links: doc.links);
  }

  /// Original HttpResponse
  final HttpResponse http;

  /// The resource collection fetched from the server
  final IdentityCollection<Resource> collection;

  /// Included resources
  final IdentityCollection<Resource> included;

  /// Links to iterate the collection
  final links = <String, Link>{};
}
