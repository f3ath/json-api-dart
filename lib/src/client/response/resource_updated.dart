import 'package:http_interop/http_interop.dart';
import 'package:json_api/document.dart';

class ResourceUpdated {
  ResourceUpdated(this.httpResponse, Map? json) : resource = _resource(json) {
    if (json != null) {
      included.addAll(InboundDocument(json).included());
      meta.addAll(InboundDocument(json).meta());
      links.addAll(InboundDocument(json).links());
    }
  }

  static Resource? _resource(Map? json) {
    if (json != null) {
      final doc = InboundDocument(json);
      if (doc.hasData) {
        return doc.dataAsResource();
      }
    }
    return null;
  }

  final Response httpResponse;

  /// The created resource. Null for "204 No Content" responses.
  late final Resource? resource;

  /// Top-level meta data
  final meta = <String, Object?>{};

  /// Top-level links
  final links = <String, Link>{};

  /// Included resources
  final included = <Resource>[];
}
