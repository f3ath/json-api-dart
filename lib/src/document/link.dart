import 'package:json_api/src/document/parsing.dart';
import 'package:json_api/src/document/validation.dart';

/// A JSON:API link
/// https://jsonapi.org/format/#document-links
class Link implements Validatable {
  final String href;

  Link(String this.href) {
    ArgumentError.checkNotNull(href, 'href');
  }

  Uri get uri => Uri.parse(href);

  factory Link.fromJson(Object json) {
    if (json is String) return Link(json);
    if (json is Map) return LinkObject.fromJson(json);
    throw ParseError(Link, json);
  }

  static Map<String, Link> parseMap(Map m) {
    final links = <String, Link>{};
    m.forEach((k, v) => links[k] = Link.fromJson(v));
    return links;
  }

  toJson() => href;

  validate(Naming naming) => [];
}

/// A JSON:API link object
/// https://jsonapi.org/format/#document-links
class LinkObject extends Link {
  final meta = <String, Object>{};

  LinkObject(String href, {Map<String, Object> meta}) : super(href) {
    this.meta.addAll(meta ?? {});
  }

  LinkObject.fromJson(Map json) : this(json['href'], meta: json['meta']);

  toJson() {
    final json = <String, Object>{'href': href};
    if (meta != null && meta.isNotEmpty) json['meta'] = meta;
    return json;
  }

  validate(Naming naming) =>
      naming.violations('/meta', meta.keys.toList()).toList();
}

class PaginationLinks {
  final Link first;
  final Link last;
  final Link prev;
  final Link next;

  PaginationLinks({this.next, this.first, this.last, this.prev});

  PaginationLinks.fromMap(Map<String, Link> links)
      : this(
            first: links['first'],
            last: links['last'],
            next: links['next'],
            prev: links['prev']);

  Map<String, Link> get asMap =>
      {'first': first, 'last': last, 'prev': prev, 'next': next};
}
