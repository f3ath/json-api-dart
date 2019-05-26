import 'package:json_api/src/server/request_target.dart';

abstract class UriSchema {
  Uri collection(String type);

  Uri related(String type, String id, String relationship);

  Uri relationship(String type, String id, String relationship);

  Uri resource(String type, String id);
}

/// The routing schema (URL Design) defines the design of URLs used by the server.
class Routing implements UriSchema {
  final Uri _base;

  Routing(this._base) {
    ArgumentError.checkNotNull(_base, 'base');
  }

  /// Builds a URL for a resource collection
  Uri collection(String type) => _path([type]);

  /// Builds a URL for a related resource
  Uri related(String type, String id, String relationship) =>
      _path([type, id, relationship]);

  /// Builds a URL for a relationship object
  Uri relationship(String type, String id, String relationship) =>
      _path([type, id, 'relationships', relationship]);

  /// Builds a URL for a single resource
  Uri resource(String type, String id) => _path([type, id]);

  /// This function must return one of the following:
  /// - [CollectionTarget]
  /// - [ResourceTarget]
  /// - [RelationshipTarget]
  /// - [RelatedTarget]
  /// - null if the target can not be determined
  RequestTarget getTarget(Uri uri) {
    final seg = uri.pathSegments;
    switch (seg.length) {
      case 1:
        return CollectionTarget(seg[0]);
      case 2:
        return ResourceTarget(seg[0], seg[1]);
      case 3:
        return RelatedTarget(seg[0], seg[1], seg[2]);
      case 4:
        if (seg[2] == 'relationships') {
          return RelationshipTarget(seg[0], seg[1], seg[3]);
        }
    }
    return null;
  }

  Uri _path(List<String> segments) =>
      _base.replace(pathSegments: _base.pathSegments + segments);
}
