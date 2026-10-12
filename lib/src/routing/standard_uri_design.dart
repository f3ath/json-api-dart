import 'package:json_api/routing.dart';

/// URL Design recommended by the standard.
/// See https://jsonapi.org/recommendations/#urls
class StandardUriDesign(Uri baseUri) implements UriDesign {
  /// Creates an instance of [UriDesign] recommended by JSON:API standard.
  /// The [base] URI will be used as a prefix for the generated URIs.
  this : base = baseUri.path.endsWith('/') ? baseUri : baseUri.replace(path: '${baseUri.path}/');

  /// A "path only" version of the recommended URL design, e.g.
  /// `/books`, `/books/42`, `/books/42/authors`
  static final pathOnly = StandardUriDesign(Uri(path: '/'));

  /// Matches a [uri] to a [Target] object.
  @override
  Target? target(Uri uri) =>
      !uri.path.startsWith(base.path) ||
          (base.scheme.isNotEmpty && uri.scheme != base.scheme) ||
          (base.host.isNotEmpty && uri.host != base.host) ||
          (base.port != 0 && uri.port != base.port)
      ? null
      : switch (uri.pathSegments.sublist(base.pathSegments.where((it) => it.isNotEmpty).length)) {
          [var type] => CollectionTarget(type),
          [var type, var id] => ResourceTarget(type, id),
          [var type, var id, var rel] => RelatedTarget(type, id, rel),
          [var type, var id, 'relationships', var rel] => RelationshipTarget(type, id, rel),
          _ => null,
        };

  final Uri base;

  @override
  Uri uri(Target target) => switch (target) {
    CollectionTarget(type: String type) => _resolve([type]),
    ResourceTarget(type: String type, id: String id) => _resolve([type, id]),
    RelatedTarget(type: String type, id: String id, relationship: String rel) => _resolve([
      type,
      id,
      rel,
    ]),
    RelationshipTarget(type: String type, id: String id, relationship: String rel) => _resolve([
      type,
      id,
      'relationships',
      rel,
    ]),
  };

  Uri _resolve(List<String> pathSegments) => base.resolveUri(Uri(pathSegments: pathSegments));
}
