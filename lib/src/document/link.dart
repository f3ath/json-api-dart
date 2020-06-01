import 'package:maybe_just_nothing/maybe_just_nothing.dart';

/// A JSON:API link
/// https://jsonapi.org/format/#document-links
class Link {
  Link(this.uri, {Map<String, Object> meta = const {}})
      : meta = Map.unmodifiable(meta ?? const {}) {
    ArgumentError.checkNotNull(uri, 'uri');
  }

  final Uri uri;
  final Map<String, Object> meta;

  /// Reconstructs the link from the [json] object
  static Link fromJson(dynamic json) {
    if (json is String) return Link(Uri.parse(json));
    if (json is Map) {
      return Link(
          Maybe(json['href']).cast<String>().map(Uri.parse).orGet(() => Uri()),
          meta: Maybe(json['meta']).cast<Map>().or(const {}));
    }
    throw FormatException(
        'A JSON:API link must be a JSON string or a JSON object');
  }

  /// Reconstructs the document's `links` member into a map.
  /// Details on the `links` member: https://jsonapi.org/format/#document-links
  static Map<String, Link> mapFromJson(dynamic json) => Maybe(json)
      .cast<Map>()
      .map((_) => _.map((k, v) => MapEntry(k.toString(), Link.fromJson(v))))
      .or(const {});

  @override
  String toString() => uri.toString();
}
