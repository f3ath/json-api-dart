/// A JSON:API link
/// https://jsonapi.org/format/#document-links
class Link {
  final Uri uri;

  Link(this.uri) {
    ArgumentError.checkNotNull(uri, 'uri');
  }

  toJson() => uri.toString();

  @override
  String toString() => uri.toString();
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
