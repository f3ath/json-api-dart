import 'package:http_interop/http_interop.dart' as i;
import 'package:json_api/document.dart';
import 'package:json_api/src/client/response.dart';

/// A response to fetch a primary resource request
class ResourceFetched {
  ResourceFetched(this.rawResponse) {
    final document = InboundDocument(rawResponse.document ??
        (throw FormatException('The document must not be empty')));
    resource = document.dataAsResource();
    included.addAll(document.included());
    meta.addAll(document.meta());
    links.addAll(document.links());
  }

  // coverage:ignore-start
  /// The raw HTTP response
  @Deprecated('Use rawResponse.httpResponse instead')
  i.Response get httpResponse => rawResponse.httpResponse;
  // coverage:ignore-end

  /// The raw JSON:API response
  final Response rawResponse;

  late final Resource resource;

  /// Top-level meta data
  final meta = <String, Object?>{};

  /// Top-level links
  final links = <String, Link>{};

  /// Included resources
  final included = <Resource>[];
}
