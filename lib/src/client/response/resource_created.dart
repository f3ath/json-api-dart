import 'package:json_api/document.dart';
import 'package:json_api/src/client/response.dart';

/// A response to a new resource creation request.
/// This is always a "201 Created" response.
///
/// https://jsonapi.org/format/#crud-creating-responses-201
class ResourceCreated {
  ResourceCreated(this.rawResponse) {
    final document = InboundDocument(rawResponse.document ??
        (throw FormatException('The document must not be empty')));
    resource = document.dataAsResource();
    included.addAll(document.included());
    meta.addAll(document.meta());
    links.addAll(document.links());
  }

  /// The raw JSON:API response
  final Response rawResponse;

  /// Created resource.
  late final Resource resource;

  /// Top-level meta data
  final meta = <String, Object?>{};

  /// Top-level links
  final links = <String, Link>{};

  /// Included resources
  final included = <Resource>[];
}
