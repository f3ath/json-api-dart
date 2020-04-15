import 'package:json_api/src/routing/composite_routing.dart';
import 'package:json_api/src/routing/contract.dart';

/// The standard (recommended) URI design
class StandardRouting extends CompositeRouting {
  StandardRouting([Uri base])
      : super(StandardCollection(base), StandardResource(base),
            StandardRelated(base), StandardRelationship(base));
}

/// The recommended URI design for a primary resource collections.
/// Example: `/photos`
///
/// See: https://jsonapi.org/recommendations/#urls-resource-collections
class StandardCollection extends _BaseRoute implements CollectionUriPattern {
  StandardCollection([Uri base]) : super(base);

  @override
  bool match(Uri uri, Function(String type) onMatch) {
    final seg = _segments(uri);
    if (seg.length == 1) {
      onMatch(seg.first);
      return true;
    }
    return false;
  }

  @override
  Uri uri(String type) => _resolve([type]);
}

/// The recommended URI design for a primary resource.
/// Example: `/photos/1`
///
/// See: https://jsonapi.org/recommendations/#urls-individual-resources
class StandardResource extends _BaseRoute implements ResourceUriPattern {
  StandardResource([Uri base]) : super(base);

  @override
  bool match(Uri uri, Function(String type, String id) onMatch) {
    final seg = _segments(uri);
    if (seg.length == 2) {
      onMatch(seg.first, seg.last);
      return true;
    }
    return false;
  }

  @override
  Uri uri(String type, String id) => _resolve([type, id]);
}

/// The recommended URI design for a related resource or collections.
/// Example: `/photos/1/comments`
///
/// See: https://jsonapi.org/recommendations/#urls-relationships
class StandardRelated extends _BaseRoute implements RelatedUriPattern {
  StandardRelated([Uri base]) : super(base);

  @override
  bool match(Uri uri, Function(String type, String id, String rel) onMatch) {
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
}

/// The recommended URI design for a relationship.
/// Example: `/photos/1/relationships/comments`
///
/// See: https://jsonapi.org/recommendations/#urls-relationships
class StandardRelationship extends _BaseRoute
    implements RelationshipUriPattern {
  StandardRelationship([Uri base]) : super(base);

  @override
  bool match(Uri uri, Function(String type, String id, String rel) onMatch) {
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
