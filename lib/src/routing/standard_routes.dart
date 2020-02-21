import 'package:json_api/src/routing/collection_route.dart';
import 'package:json_api/src/routing/relationship_route.dart';
import 'package:json_api/src/routing/resource_route.dart';

class StandardCollectionRoute extends _BaseRoute implements CollectionRoute {
  @override
  bool match(Uri uri, void Function(String type) onMatch) {
    final seg = _segments(uri);
    if (seg.length == 1) {
      onMatch(seg.first);
      return true;
    }
    return false;
  }

  @override
  Uri uri(String type) => _resolve([type]);

  StandardCollectionRoute([Uri base]) : super(base);
}

class StandardResourceRoute extends _BaseRoute implements ResourceRoute {
  @override
  bool match(Uri uri, void Function(String type, String id) onMatch) {
    final seg = _segments(uri);
    if (seg.length == 2) {
      onMatch(seg.first, seg.last);
      return true;
    }
    return false;
  }

  @override
  Uri uri(String type, String id) => _resolve([type, id]);

  StandardResourceRoute([Uri base]) : super(base);
}

class StandardRelatedRoute extends _BaseRoute implements RelationshipRoute {
  @override
  bool match(Uri uri,
      void Function(String type, String id, String relationship) onMatch) {
    final seg = _segments(uri);
    if (seg.length == 3) {
      onMatch(seg.first, seg[1], seg.last);
      return true;
    }
    return false;
  }

  @override
  Uri uri(String type, String id, String relationship) =>
      _resolve([type, id, relationship]);

  StandardRelatedRoute([Uri base]) : super(base);
}

class StandardRelationshipRoute extends _BaseRoute
    implements RelationshipRoute {
  @override
  bool match(Uri uri,
      void Function(String type, String id, String relationship) onMatch) {
    final seg = _segments(uri);
    if (seg.length == 4 && seg[2] == _rel) {
      onMatch(seg.first, seg[1], seg.last);
      return true;
    }
    return false;
  }

  @override
  Uri uri(String type, String id, String relationship) =>
      _resolve([type, id, _rel, relationship]);

  StandardRelationshipRoute([Uri base]) : super(base);

  static const _rel = 'relationships';
}

class _BaseRoute {
  _BaseRoute([Uri base]) : _base = base ?? Uri(path: '/');

  final Uri _base;

  Uri _resolve(List<String> pathSegments) =>
      _base.resolveUri(Uri(pathSegments: pathSegments));

  List<String> _segments(Uri uri) =>
      uri.pathSegments.skip(_base.pathSegments.length).toList();
}
