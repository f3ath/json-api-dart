/// A JSON:API link
/// https://jsonapi.org/format/#document-links
class Link {
  final Uri uri;

  Link(this.uri) {
    ArgumentError.checkNotNull(uri, 'uri');
  }

  static Link parse(Object json) {
    if (json is String) return Link(Uri.parse(json));
    if (json is Map) {
      return LinkObject(Uri.parse(json['href']), meta: json['meta']);
    }
    throw 'Can not parse Link from $json';
  }

  /// Parses the document's `links` member into a map.
  /// The retuning map does not have null values.
  ///
  /// Details on the `links` member: https://jsonapi.org/format/#document-links
  static Map<String, Link> parseLinks(Object json) {
    if (json == null) return {};
    if (json is Map) {
      return (json..removeWhere((_, v) => v == null))
          .map((k, v) => MapEntry(k.toString(), parse(v)));
    }
    throw 'Can not parse links from $json';
  }

  toJson() => uri.toString();
}

/// A JSON:API link object
/// https://jsonapi.org/format/#document-links
class LinkObject extends Link {
  final Map<String, Object> meta;

  LinkObject(Uri href, {Map<String, Object> meta})
      : meta = Map.unmodifiable(meta ?? {}),
        super(href);

  toJson() {
    final json = <String, Object>{'href': uri.toString()};
    if (meta != null && meta.isNotEmpty) json['meta'] = meta;
    return json;
  }
}

class Links {
  final Map<String, Link> links;

  Links(Map<String, Link> links) : links = Map.unmodifiable(links);

  static Links fromJson(Object json) {
    if (json is Map) {
      return Links(Map.fromEntries(
          json.entries.map((e) => MapEntry(e.key, Link.parse(e.value)))));
    }
    throw 'Can not parse Links from $json';
  }

  toJson() => {}
    ..addAll(links)
    ..removeWhere((k, v) => v == null);
}
