import 'package:json_api/src/routing/collection_uri.dart';
import 'package:json_api/src/routing/related_uri.dart';
import 'package:json_api/src/routing/relationship_uri.dart';
import 'package:json_api/src/routing/resource_uri.dart';
import 'package:json_api/src/routing/routing.dart';

/// The recommended route design.
/// See https://jsonapi.org/recommendations/#urls
class RecommendedRouting implements Routing {
  @override
  final CollectionUri collection;

  @override
  final RelatedUri related;

  @override
  final RelationshipUri relationship;

  @override
  final ResourceUri resource;

  /// Creates an instance of
  RecommendedRouting(Uri base)
      : collection = _Collection(base),
        resource = _Resource(base),
        related = _Related(base),
        relationship = _Relationship(base);
}

class _Collection extends _Recommended implements CollectionUri {
  @override
  Uri uri(String type) => _append([type]);

  @override
  bool match(Uri uri, void Function(String type) onMatch) {
    final seg = _segments(uri);
    if (seg.length == 1) {
      onMatch(seg[0]);
      return true;
    }
    return false;
  }

  const _Collection(Uri base) : super(base);
}

class _Resource extends _Recommended implements ResourceUri {
  @override
  Uri uri(String type, String id) => _append([type, id]);

  @override
  bool match(Uri uri, void Function(String type, String id) onMatch) {
    final seg = _segments(uri);
    if (seg.length == 2) {
      onMatch(seg[0], seg[1]);
      return true;
    }
    return false;
  }

  const _Resource(Uri base) : super(base);
}

class _Related extends _Recommended implements RelatedUri {
  @override
  Uri uri(String type, String id, String relationship) =>
      _append([type, id, relationship]);

  @override
  bool match(Uri uri,
      void Function(String type, String id, String relationship) onMatch) {
    final seg = _segments(uri);
    if (seg.length == 3) {
      onMatch(seg[0], seg[1], seg[3]);
      return true;
    }
    return false;
  }

  const _Related(Uri base) : super(base);
}

class _Relationship extends _Recommended implements RelationshipUri {
  @override
  Uri uri(String type, String id, String relationship) =>
      _append([type, id, _relationships, relationship]);

  @override
  bool match(Uri uri,
      void Function(String type, String id, String relationship) onMatch) {
    final seg = _segments(uri);
    if (seg.length == 4 && seg[2] == _relationships) {
      onMatch(seg[0], seg[1], seg[3]);
      return true;
    }
    return false;
  }

  const _Relationship(Uri base) : super(base);
  static const _relationships = 'relationships';
}

class _Recommended {
  Uri _append(Iterable<String> segments) =>
      _base.replace(pathSegments: _base.pathSegments + segments);

  List<String> _segments(Uri uri) =>
      uri.pathSegments.sublist(_base.pathSegments.length);

  const _Recommended(this._base);

  final Uri _base;
}
