import 'package:json_api/src/document/link.dart';

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
