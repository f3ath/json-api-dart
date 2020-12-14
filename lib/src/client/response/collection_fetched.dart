import 'package:json_api/document.dart';
import 'package:json_api/http.dart';

class CollectionFetched {
  CollectionFetched(this.http, Map json) {
    final document = InboundDocument(json);
    collection.addAll(document.dataAsCollection());
    included.addAll(document.included());
    meta.addAll(document.meta());
    links.addAll(document.links());
  }

  final HttpResponse http;

  /// The resource collection fetched from the server
  final collection = ResourceCollection();

  /// Included resources
  final included = ResourceCollection();

  /// Top-level meta data
  final meta = <String, Object?>{};

  /// Top-level links object
  final links = <String, Link>{};
}
