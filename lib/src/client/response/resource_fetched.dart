import 'package:http_interop/http_interop.dart';
import 'package:json_api/document.dart';

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

  /// Top-level meta data
  final meta = <String, Object?>{};

  /// Top-level links
  final links = <String, Link>{};

  /// Included resources
  final included = <Resource>[];
}
