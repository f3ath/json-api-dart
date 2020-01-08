import 'package:json_api/src/url_design/url_design.dart';

/// URL Design where the target is determined by the URL path.
/// This is the recommended design according to the JSON:API standard.
/// @see https://jsonapi.org/recommendations/#urls
class PathBasedUrlDesign implements UrlDesign {
  static const _relationships = 'relationships';

  /// The base to be added the the generated URIs
  final Uri base;

  /// Check incoming URIs match the [base]
  final bool matchBase;

  PathBasedUrlDesign(this.base, {this.matchBase = false});

  /// Creates an instance with "/" as the base URI.
  static UrlDesign relative() => PathBasedUrlDesign(Uri());

  /// Returns a URL for the primary resource collection of type [type]
  @override
  Uri collection(String type) => _appendToBase([type]);

  /// Returns a URL for the related resource/collection.
  /// The [type] and [id] identify the primary resource and the [relationship]
  /// is the relationship name.
  @override
  Uri related(String type, String id, String relationship) =>
      _appendToBase([type, id, relationship]);

  /// Returns a URL for the relationship itself.
  /// The [type] and [id] identify the primary resource and the [relationship]
  /// is the relationship name.
  @override
  Uri relationship(String type, String id, String relationship) =>
      _appendToBase([type, id, _relationships, relationship]);

  /// Returns a URL for the primary resource of type [type] with id [id]
  @override
  Uri resource(String type, String id) => _appendToBase([type, id]);

  @override
  T match<T>(final Uri uri, final MatchCase<T> matchCase) {
    if (!matchBase || _matchesBase(uri)) {
      final seg = uri.pathSegments.sublist(base.pathSegments.length);
      if (seg.length == 1) {
        return matchCase.collection(seg[0]);
      }
      if (seg.length == 2) {
        return matchCase.resource(seg[0], seg[1]);
      }
      if (seg.length == 3) {
        return matchCase.related(seg[0], seg[1], seg[2]);
      }
      if (seg.length == 4 && seg[2] == _relationships) {
        return matchCase.relationship(seg[0], seg[1], seg[3]);
      }
    }
    return matchCase.unmatched();
  }

  Uri _appendToBase(List<String> segments) =>
      base.replace(pathSegments: base.pathSegments + segments);

  bool _matchesBase(Uri uri) =>
      base.host == uri.host &&
      base.port == uri.port &&
      uri.path.startsWith(base.path);
}
