import 'package:json_api/src/document/decoding_exception.dart';

/// A JSON:API link
/// https://jsonapi.org/format/#document-links
class Link {
  final Uri uri;

  Link(this.uri) {
    ArgumentError.checkNotNull(uri, 'uri');
  }

  /// Reconstructs the link from the [json] object. If [json] is null, returns null;
  static Link fromJson(Object json) {
    if (json == null) return null;
    if (json is String) return Link(Uri.parse(json));
    if (json is Map) return LinkObject.fromJson(json);
    throw DecodingException('Can not decode Link from $json');
  }

  /// Reconstructs the document's `links` member into a map.
  /// The retuning map will not have null values.
  ///
  /// Details on the `links` member: https://jsonapi.org/format/#document-links
  static Map<String, Link> mapFromJson(Object json) {
    if (json == null) return {};
    if (json is Map) {
      return ({...json}..removeWhere((_, v) => v == null))
          .map((k, v) => MapEntry(k.toString(), Link.fromJson(v)));
    }
    throw DecodingException('Can not decode links map from $json');
  }

  toJson() => uri.toString();

  @override
  String toString() => uri.toString();
}

/// A JSON:API link object
/// https://jsonapi.org/format/#document-links
class LinkObject extends Link {
  final Map<String, Object> meta;

  LinkObject(Uri href, {this.meta}) : super(href);

  static LinkObject fromJson(Object json) {
    if (json is Map) {
      final href = json['href'];
      if (href is String) {
        return LinkObject(Uri.parse(href), meta: json['meta']);
      }
    }
    throw DecodingException('Can not decode LinkObject from $json');
  }

  toJson() => {
        'href': uri.toString(),
        if (meta != null && meta.isNotEmpty) ...{'meta': meta}
      };
}
