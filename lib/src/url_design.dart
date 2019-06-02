/// URL Design is how the endpoints are organized.
abstract class UrlDesign {
  factory UrlDesign.recommended(String base) =>
      RecommendedUrlDesign(Uri.parse(base));

  /// Returns a URL for a primary resource collection of type [type]
  Uri collection(String type);

  /// Returns a URL for a related resource/collection.
  /// The [type] and [id] identify the primary resource and the [relationship]
  /// is the relationship name.
  Uri related(String type, String id, String relationship);

  /// Returns a URL for a relationship itself.
  /// The [type] and [id] identify the primary resource and the [relationship]
  /// is the relationship name.
  Uri relationship(String type, String id, String relationship);

  /// Returns a URL for a primary resource collection of type [type] and id [id]
  Uri resource(String type, String id);
}

class RecommendedUrlDesign implements UrlDesign {
  final Uri base;

  const RecommendedUrlDesign(this.base);

  Uri collection(String type) => _path([type]);

  Uri related(String type, String id, String relationship) =>
      _path([type, id, relationship]);

  Uri relationship(String type, String id, String relationship) =>
      _path([type, id, 'relationships', relationship]);

  Uri resource(String type, String id) => _path([type, id]);

  Uri _path(List<String> segments) =>
      base.replace(pathSegments: base.pathSegments + segments);
}
