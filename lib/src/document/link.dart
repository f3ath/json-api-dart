import 'package:json_api/src/document/parsing.dart';
import 'package:json_api/src/document/validation.dart';

/// A JSON:API link
/// https://jsonapi.org/format/#document-links
class Link implements Validatable {
  final Uri href;

  Link(this.href) {
    ArgumentError.checkNotNull(href, 'href');
  }

  static Link fromString(String href) => Link(Uri.parse(href));

  static Link fromJson(Object json) {
    if (json is String) return Link(Uri.parse(json));
    if (json is Map) return LinkObject.fromJson(json);
    throw ParseError(Link, json);
  }

  static Map<String, Link> parseMap(Map m) {
    final links = <String, Link>{};
    m.forEach((k, v) => links[k] = Link.fromJson(v));
    return links;
  }

  toJson() => href.toString();

  validate(Naming naming) => [];
}

/// A JSON:API link object
/// https://jsonapi.org/format/#document-links
class LinkObject extends Link {
  final meta = <String, Object>{};

  LinkObject(Uri href, {Map<String, Object> meta}) : super(href) {
    this.meta.addAll(meta ?? {});
  }

  LinkObject.fromJson(Map json) : this(Uri.parse(json['href']), meta: json['meta']);

  toJson() {
    final json = <String, Object>{'href': href.toString()};
    if (meta != null && meta.isNotEmpty) json['meta'] = meta;
    return json;
  }

  validate(Naming naming) =>
      naming.violations('/meta', meta.keys.toList()).toList();
}
