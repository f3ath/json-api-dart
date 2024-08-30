import 'package:http_interop/http_interop.dart' as i;
import 'package:json_api/document.dart';
import 'package:json_api/src/client/response.dart';

class ResourceUpdated {
  ResourceUpdated(this.rawResponse)
      : resource = _resource(rawResponse.document) {
    final document = rawResponse.document;
    if (document != null) {
      included.addAll(InboundDocument(document).included());
      meta.addAll(InboundDocument(document).meta());
      links.addAll(InboundDocument(document).links());
    }
  }

  static Resource? _resource(Map? json) {
    if (json != null) {
      final doc = InboundDocument(json);
      if (doc.hasData) return doc.dataAsResource();
    }
    return null;
  }

  // coverage:ignore-start
  /// The raw HTTP response
  @Deprecated('Use rawResponse.httpResponse instead')
  i.Response get httpResponse => rawResponse.httpResponse;
  // coverage:ignore-end

  /// The raw JSON:API response
  final Response rawResponse;

  /// The created resource. Null for "204 No Content" responses.
  late final Resource? resource;

  /// Top-level meta data
  final meta = <String, Object?>{};

  /// Top-level links
  final links = <String, Link>{};

  /// Included resources
  final included = <Resource>[];
}
