import 'package:json_api/src/document/document_exception.dart';
import 'package:json_api/src/document/meta.dart';

/// A JSON:API link
/// https://jsonapi.org/format/#document-links
class Link with Meta {
  Link(this.uri, {Map<String, Object> meta}) {
    ArgumentError.checkNotNull(uri, 'uri');
    this.meta.addAll(meta ?? {});
  }

  final Uri uri;

  /// Reconstructs the link from the [json] object
  static Link fromJson(Object json) {
    if (json is String) return Link(Uri.parse(json));
    if (json is Map) {
      return Link(Uri.parse(json['href']), meta: json['meta']);
    }
    throw DocumentException(
        'A JSON:API link must be a JSON string or a JSON object');
  }

  /// Reconstructs the document's `links` member into a map.
  /// Details on the `links` member: https://jsonapi.org/format/#document-links
  static Map<String, Link> mapFromJson(Object json) {
    if (json is Map) {
      return json.map((k, v) => MapEntry(k.toString(), Link.fromJson(v)));
    }
    throw DocumentException('A JSON:API links object must be a JSON object');
  }

  Object toJson() =>
      meta.isEmpty ? uri.toString() : {'href': uri.toString(), 'meta': meta};

  @override
  String toString() => uri.toString();
}
