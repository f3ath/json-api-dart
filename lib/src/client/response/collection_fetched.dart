import 'package:http_interop/http_interop.dart' as interop;
import 'package:json_api/document.dart';

class CollectionFetched {
  CollectionFetched(this.http, Map json) {
    final document = InboundDocument(json);
    collection.addAll(document.dataAsCollection());
    included.addAll(document.included());
    meta.addAll(document.meta());
    links.addAll(document.links());
  }

  final interop.Response http;

  /// The resource collection fetched from the server
  final collection = <Resource>[];

  /// Included resources
  final included = <Resource>[];

  /// Top-level meta data
  final meta = <String, Object?>{};

  /// Top-level links object
  final links = <String, Link>{};
}
