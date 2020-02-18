/// Makes URIs for specific targets
abstract class Routing {
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

class StandardRouting implements Routing {
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

  const StandardRouting(this._base);

  static const _relationships = 'relationships';

  /// The base to be added the the generated URIs
  final Uri _base;

  Uri _appendToBase(List<String> segments) =>
      _base.replace(pathSegments: _base.pathSegments + segments);
}
