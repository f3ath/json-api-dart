import 'package:http_interop/http_interop.dart';
import 'package:json_api/document.dart';

/// A response to a new resource creation request.
/// This is always a "201 Created" response.
///
/// https://jsonapi.org/format/#crud-creating-responses-201
class ResourceCreated {
  ResourceCreated(this.httpResponse, Map json)
      : resource = InboundDocument(json).dataAsResource() {
    meta.addAll(InboundDocument(json).meta());
    links.addAll(InboundDocument(json).links());
    included.addAll(InboundDocument(json).included());
  }

  final Response httpResponse;

  /// Created resource.
  final Resource resource;

  /// Top-level meta data
  final meta = <String, Object?>{};

  /// Top-level links
  final links = <String, Link>{};

  /// Included resources
  final included = <Resource>[];
}
