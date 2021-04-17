import 'package:json_api/document.dart';
import 'package:json_api/http.dart';

/// A response to fetch a primary resource request
class ResourceFetched {
  ResourceFetched(this.http, Map json)
      : resource = InboundDocument(json).dataAsResource() {
    included.addAll(InboundDocument(json).included());
    meta.addAll(InboundDocument(json).meta());
    links.addAll(InboundDocument(json).links());
  }

  final HttpResponse http;
  final Resource resource;
  final included = ResourceCollection();

  /// Top-level meta data
  final meta = <String, Object?>{};

  /// Top-level links object
  final links = <String, Link>{};
}
