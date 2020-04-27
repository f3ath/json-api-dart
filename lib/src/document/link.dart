import 'package:json_api/src/document/document_exception.dart';

/// A JSON:API link
/// https://jsonapi.org/format/#document-links
class Link {
  Link(this.uri) {
    ArgumentError.checkNotNull(uri, 'uri');
  }

  final Uri uri;

  /// Reconstructs the link from the [json] object
  static Link fromJson(Object json) {
    if (json is String) return Link(Uri.parse(json));
    if (json is Map) {
      final href = json['href'];
      if (href is String) {
        return LinkObject(Uri.parse(href), meta: json['meta']);
      }
    }
    throw DocumentException(
        'A JSON:API link must be a JSON string or a JSON object');
  }

  /// Reconstructs the document's `links` member into a map.
  /// Details on the `links` member: https://jsonapi.org/format/#document-links
  static Map<String, Link> mapFromJson(Object json) {
    if (json is Map) {
      return Map.unmodifiable(({...json}..removeWhere((_, v) => v == null))
          .map((k, v) => MapEntry(k.toString(), Link.fromJson(v))));
    }
    throw DocumentException('A JSON:API links object must be a JSON object');
  }

  Object toJson() => uri.toString();

  @override
  String toString() => uri.toString();
}

/// A JSON:API link object
/// https://jsonapi.org/format/#document-links
class LinkObject extends Link {
  LinkObject(Uri href, {Map<String, Object> meta})
      : meta = Map.unmodifiable(meta ?? const {}),
        super(href);

  final Map<String, Object> meta;

  @override
  Map<String, Object> toJson() => {
        'href': uri.toString(),
        if (meta.isNotEmpty) 'meta': meta,
      };
}
