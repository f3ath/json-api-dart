import 'package:json_api/src/parsing.dart';
import 'package:json_api/src/validation.dart';

/// A JSON:API link
/// https://jsonapi.org/format/#document-links
class Link implements Validatable {
  final String href;

  Link(String this.href) {
    ArgumentError.checkNotNull(href, 'href');
  }

  toJson() => href;

  factory Link.fromJson(Object json) {
    if (json is String) return Link(json);
    if (json is Map) return LinkObject.fromJson(json);
    throw ParseError(Link, json);
  }

  validate([Naming naming = const StandardNaming()]) => [];
}

/// A JSON:API link object
/// https://jsonapi.org/format/#document-links
class LinkObject extends Link {
  final meta = <String, Object>{};

  LinkObject(String href, {Map<String, Object> meta}) : super(href) {
    this.meta.addAll(meta ?? {});
  }

  toJson() {
    final json = <String, Object>{'href': href};
    if (meta != null && meta.isNotEmpty) json['meta'] = meta;
    return json;
  }

  factory LinkObject.fromJson(Map json) =>
      LinkObject(json['href'], meta: json['meta']);

  validate([Naming naming = const StandardNaming()]) =>
      naming.violations('/meta', (meta).keys);
}

abstract class LinkFactory {
  Link collection(String type, {Map<String, String> queryParameters});

  Link resource(String type, String id);

  Link related(String type, String id, String name);

  Link relationship(String type, String id, String name);
}

class StandardLinks implements LinkFactory {
  final Uri base;

  StandardLinks(this.base) {
    ArgumentError.checkNotNull(base, 'base');
  }

  Link collection(String type, {Map<String, String> queryParameters}) =>
      Link(base
          .replace(
              pathSegments: base.pathSegments.followedBy([type]),
              queryParameters: _nullify({}
                ..addAll(base.queryParameters)
                ..addAll(queryParameters ?? {})))
          .toString());

  Link related(String type, String id, String name) => Link(base
      .replace(pathSegments: base.pathSegments.followedBy([type, id, name]))
      .toString());

  Link relationship(String type, String id, String name) => Link(base
      .replace(
          pathSegments:
              base.pathSegments.followedBy([type, id, 'relationships', name]))
      .toString());

  Link resource(String type, String id) => Link(base
      .replace(pathSegments: base.pathSegments.followedBy([type, id]))
      .toString());

  Map<K, V> _nullify<K, V>(Map<K, V> map) =>
      map?.isNotEmpty == true ? map : null;
}
