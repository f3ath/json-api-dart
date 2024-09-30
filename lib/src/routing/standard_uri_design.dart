import 'package:json_api/routing.dart';

/// URL Design recommended by the standard.
/// See https://jsonapi.org/recommendations/#urls
class StandardUriDesign implements UriDesign {
  /// Creates an instance of [UriDesign] recommended by JSON:API standard.
  /// The [base] URI will be used as a prefix for the generated URIs.
  StandardUriDesign(Uri base)
      : base = base.path.endsWith('/')
            ? base
            : base.replace(path: '${base.path}/');

  /// A "path only" version of the recommended URL design, e.g.
  /// `/books`, `/books/42`, `/books/42/authors`
  static final pathOnly = StandardUriDesign(Uri(path: '/'));

  /// Matches a [uri] to a [Target] object.
  Target? matchTarget(Uri uri) => !uri.path.startsWith(base.path) ||
          (base.scheme.isNotEmpty && uri.scheme != base.scheme) ||
          (base.host.isNotEmpty && uri.host != base.host) ||
          (base.port != 0 && uri.port != base.port)
      ? null
      : switch (uri.pathSegments
          .sublist(base.pathSegments.where((it) => it.isNotEmpty).length)) {
          [var type] => Target(type),
          [var type, var id] => ResourceTarget(type, id),
          [var type, var id, var rel] => RelatedTarget(type, id, rel),
          [var type, var id, 'relationships', var rel] =>
            RelationshipTarget(type, id, rel),
          _ => null
        };

  final Uri base;

  /// Returns a URL for the primary resource collection of type [type].
  /// E.g. `/books`.
  @override
  Uri collection(String type) => _resolve([type]);

  /// Returns a URL for the primary resource of type [type] with id [id].
  /// E.g. `/books/123`.
  @override
  Uri resource(String type, String id) => _resolve([type, id]);

  /// Returns a URL for the relationship itself.
  /// The [type] and [id] identify the primary resource and the [relationship]
  /// is the relationship name.
  /// E.g. `/books/123/relationships/authors`.
  @override
  Uri relationship(String type, String id, String relationship) =>
      _resolve([type, id, 'relationships', relationship]);

  /// Returns a URL for the related resource or collection.
  /// The [type] and [id] identify the primary resource and the [relationship]
  /// is the relationship name.
  /// E.g. `/books/123/authors`.
  @override
  Uri related(String type, String id, String relationship) =>
      _resolve([type, id, relationship]);

  Uri _resolve(List<String> pathSegments) =>
      base.resolveUri(Uri(pathSegments: pathSegments));
}
