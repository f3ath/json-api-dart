/// A JSON:API link
/// https://jsonapi.org/format/#document-links
class Link {
  Link(this.uri);

  /// Link URL
  final Uri uri;

  /// Link meta data
  final meta = <String, Object?>{};

  @override
  String toString() => uri.toString();

  Object toJson() =>
      meta.isEmpty ? uri.toString() : {'href': uri.toString(), 'meta': meta};
}
