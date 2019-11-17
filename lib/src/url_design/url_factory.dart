/// Makes URIs for specific targets
abstract class UrlFactory {
  /// Returns a URL for the primary resource collection of type [type]
  Uri collection(String type);

  /// Returns a URL for the related resource/collection.
  /// The [type] and [id] identify the primary resource and the [relationship]
  /// is the relationship name.
  Uri related(String type, String id, String relationship);

  /// Returns a URL for the relationship itself.
  /// The [type] and [id] identify the primary resource and the [relationship]
  /// is the relationship name.
  Uri relationship(String type, String id, String relationship);

  /// Returns a URL for the primary resource of type [type] with id [id]
  Uri resource(String type, String id);
}
