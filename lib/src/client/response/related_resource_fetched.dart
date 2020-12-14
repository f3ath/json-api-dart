import 'package:json_api/document.dart';
import 'package:json_api/http.dart';

/// A related resource response.
///
/// https://jsonapi.org/format/#fetching-resources-responses
class RelatedResourceFetched {
  RelatedResourceFetched(this.http, Map json)
      : resource = InboundDocument(json).dataAsResourceOrNull() {
    final document = InboundDocument(json);
    included.addAll(document.included());
    meta.addAll(document.meta());
    links.addAll(document.links());
  }

  final HttpResponse http;

  /// Related resource. May be null
  final Resource? resource;

  /// Included resources
  final included = ResourceCollection();

  /// Top-level meta data
  final meta = <String, Object?>{};

  /// Top-level links object
  final links = <String, Link>{};
}
