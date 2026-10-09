import 'package:json_api/document.dart';
import 'package:json_api/src/client/response.dart';

/// A related resource response.
///
/// https://jsonapi.org/format/#fetching-resources-responses
class RelatedResourceFetched(
  /// The raw JSON:API response
  final Response rawResponse,
) {
  this {
    resource = document.dataAsResourceOrNull();
    included.addAll(document.included());
    meta.addAll(document.meta());
    links.addAll(document.links());
  }

  final document = InboundDocument(
    rawResponse.document ??
        (throw FormatException('The document must not be empty')),
  );

  /// Related resource. May be null
  late final Resource? resource;

  /// Included resources
  final included = <Resource>[];

  /// Top-level meta data
  final meta = <String, Object?>{};

  /// Top-level links object
  final links = <String, Link>{};
}
