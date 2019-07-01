im/// Routing (URL Design) describes how the endpoints are organized.
class PathBasedRouting implements Routing {
  static const _relationships = 'relationships';
  final Uri _base;

  PathBasedRouting(this._base);

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
      _base.replace(pathSegments: _base.pathSegments + segments);

  List<String> _getPathSegments(Uri uri) =>
      uri.pathSegments.sublist(_base.pathSegments.length);

  bool _isRelationship(List<String> seg) =>
      seg.length == 4 && seg[2] == _relationships;

  bool _isRelated(List<String> seg) => seg.length == 3;

  bool _isResource(List<String> seg) => seg.length == 2;

  bool _isCollection(List<String> seg) => seg.length == 1;

  bool _matchesBase(Uri uri) =>
      _base.host == uri.host &&
      _base.port == uri.port &&
      uri.path.startsWith(_base.path);
}
port 'package:json_api/src/routing/routing.dart';

/// Routing (URL Design) describes how the endpoints are organized.
class PathBasedRouting implements Routing {
  static const _relationships = 'relationships';
  final Uri _base;

  PathBasedRouting(this._base);

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
      _base.replace(pathSegments: _base.pathSegments + segments);

  List<String> _getPathSegments(Uri uri) =>
      uri.pathSegments.sublist(_base.pathSegments.length);

  bool _isRelationship(List<String> seg) =>
      seg.length == 4 && seg[2] == _relationships;

  bool _isRelated(List<String> seg) => seg.length == 3;

  bool _isResource(List<String> seg) => seg.length == 2;

  bool _isCollection(List<String> seg) => seg.length == 1;

  bool _matchesBase(Uri uri) =>
      _base.host == uri.host &&
      _base.port == uri.port &&
      uri.path.startsWith(_base.path);
}
