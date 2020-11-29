import 'package:json_api/core.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/routing/target_matcher.dart';

/// URL Design recommended by the standard.
/// See https://jsonapi.org/recommendations/#urls
class RecommendedUrlDesign implements UriFactory, TargetMatcher {
  /// Creates an instance of RecommendedUrlDesign.
  /// The [base] URI will be used as a prefix for the generated URIs.
  const RecommendedUrlDesign(this.base);

  /// A "path only" version of the recommended URL design, e.g.
  /// `/books`, `/books/42`, `/books/42/authors`
  static final pathOnly = RecommendedUrlDesign(Uri(path: '/'));

  final Uri base;

  /// Returns a URL for the primary resource collection of type [type].
  /// E.g. `/books`.
  @override
  Uri collection(CollectionTarget target) => _resolve([target.type]);

  /// Returns a URL for the primary resource of type [type] with id [id].
  /// E.g. `/books/123`.
  @override
  Uri resource(ResourceTarget target) =>
      _resolve([target.ref.type, target.ref.id]);

  /// Returns a URL for the relationship itself.
  /// The [type] and [id] identify the primary resource and the [relationship]
  /// is the relationship name.
  /// E.g. `/books/123/relationships/authors`.
  @override
  Uri relationship(RelationshipTarget target) => _resolve(
      [target.ref.type, target.ref.id, 'relationships', target.relationship]);

  /// Returns a URL for the related resource or collection.
  /// The [type] and [id] identify the primary resource and the [relationship]
  /// is the relationship name.
  /// E.g. `/books/123/authors`.
  @override
  Uri related(RelatedTarget target) =>
      _resolve([target.ref.type, target.ref.id, target.relationship]);

  @override
  Target? match(Uri uri) {
    final s = uri.pathSegments;
    if (s.length == 1) {
      return CollectionTarget(s.first);
    }
    if (s.length == 2) {
      return ResourceTarget(Ref(s.first, s.last));
    }
    if (s.length == 3) {
      return RelatedTarget(Ref(s.first, s[1]), s.last);
    }
    if (s.length == 4 && s[2] == 'relationships') {
      return RelationshipTarget(Ref(s.first, s[1]), s.last);
    }
    return null;
  }

  Uri _resolve(List<String> pathSegments) =>
      base.resolveUri(Uri(pathSegments: pathSegments));
}
