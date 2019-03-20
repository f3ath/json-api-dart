import 'package:json_api/src/server/request_target.dart';
import 'package:json_api/src/server/router.dart';

/// StandardURLDesign implements the recommended URL design schema:
///
/// - `/photos` for a collection
///
/// - `/photos/1` for a resource
///
/// - `/photos/1/relationships/author` for a relationship `author`
///
/// - `/photos/1/author` for a related resource `author`
///
/// See https://jsonapi.org/recommendations/#urls
class StandardURLDesign implements URLDesign {
  final Uri base;

  StandardURLDesign(this.base) {
    ArgumentError.checkNotNull(base, 'base');
  }

  Uri collection(CollectionTarget t) => _path([t.type]);

  Uri related(RelatedTarget t) => _path([t.type, t.id, t.relationship]);

  Uri relationship(RelationshipTarget t) =>
      _path([t.type, t.id, 'relationships', t.relationship]);

  Uri resource(ResourceTarget t) => _path([t.type, t.id]);

  RequestTarget getTarget(Uri uri) {
    final _ = uri.pathSegments;
    switch (_.length) {
      case 1:
        return CollectionTarget(_[0]);
      case 2:
        return ResourceTarget(_[0], _[1]);
      case 3:
        return RelatedTarget(_[0], _[1], _[2]);
      case 4:
        if (_[2] == 'relationships') {
          return RelationshipTarget(_[0], _[1], _[3]);
        }
    }
    return null;
  }

  Uri _path(List<String> segments) =>
      base.replace(pathSegments: base.pathSegments + segments);
}
