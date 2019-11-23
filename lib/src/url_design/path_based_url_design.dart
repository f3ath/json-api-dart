import 'package:json_api/server.dart';
import 'package:json_api/src/url_design/collection_target.dart';
import 'package:json_api/src/url_design/relationship_target.dart';
import 'package:json_api/src/url_design/resource_target.dart';
import 'package:json_api/src/url_design/url_design.dart';

/// URL Design where the target is determined by the URL path.
/// This is the recommended design according to the JSON:API standard.
/// @see https://jsonapi.org/recommendations/#urls
class PathBasedUrlDesign implements UrlDesign {
  static const _relationships = 'relationships';
  final Uri base;

  PathBasedUrlDesign(this.base);

  /// Returns a URL for the primary resource collection of type [type]
  Uri collection(String type) => _appendToBase([type]);

  /// Returns a URL for the related resource/collection.
  /// The [type] and [id] identify the primary resource and the [relationship]
  /// is the relationship name.
  Uri related(String type, String id, String relationship) =>
      _appendToBase([type, id, relationship]);

  /// Returns a URL for the relationship itself.
  /// The [type] and [id] identify the primary resource and the [relationship]
  /// is the relationship name.
  Uri relationship(String type, String id, String relationship) =>
      _appendToBase([type, id, _relationships, relationship]);

  /// Returns a URL for the primary resource of type [type] with id [id]
  Uri resource(String type, String id) => _appendToBase([type, id]);

  @override
  T matchAndMap<T>(Uri uri, TargetMapper<T> mapper) {
    if (!_matchesBase(uri)) return mapper.unmatched();
    final s = _getPathSegments(uri);
    if (_isCollection(s)) {
      return mapper.collection(CollectionTarget(s[0]));
    }
    if (_isResource(s)) {
      return mapper.resource(ResourceTarget(s[0], s[1]));
    }
    if (_isRelated(s)) {
      return mapper.related(RelationshipTarget(s[0], s[1], s[2]));
    }
    if (_isRelationship(s)) {
      return mapper.relationship(RelationshipTarget(s[0], s[1], s[3]));
    }
    return mapper.unmatched();
  }

  Uri _appendToBase(List<String> segments) =>
      base.replace(pathSegments: base.pathSegments + segments);

  List<String> _getPathSegments(Uri uri) =>
      uri.pathSegments.sublist(base.pathSegments.length);

  bool _isRelationship(List<String> seg) =>
      seg.length == 4 && seg[2] == _relationships;

  bool _isRelated(List<String> seg) => seg.length == 3;

  bool _isResource(List<String> seg) => seg.length == 2;

  bool _isCollection(List<String> seg) => seg.length == 1;

  bool _matchesBase(Uri uri) =>
      base.host == uri.host &&
      base.port == uri.port &&
      uri.path.startsWith(base.path);
}
