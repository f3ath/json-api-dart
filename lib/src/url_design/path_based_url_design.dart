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

  /// Matches the target of the [uri]. If the target can be determined,
  /// the corresponding callback will be called with the target parameters.
  void match(Uri uri,
      {onCollection(String type),
      onResource(String type, String id),
      onRelationship(String type, String id, String relationship),
      onRelated(String type, String id, String relationship)}) {
    if (!_matchesBase(uri)) return;
    final seg = _getPathSegments(uri);

    if (_isCollection(seg) && onCollection != null) {
      onCollection(seg[0]);
    } else if (_isResource(seg) && onResource != null) {
      onResource(seg[0], seg[1]);
    } else if (_isRelated(seg) && onRelated != null) {
      onRelated(seg[0], seg[1], seg[2]);
    } else if (_isRelationship(seg) && onRelationship != null) {
      onRelationship(seg[0], seg[1], seg[3]);
    }
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
