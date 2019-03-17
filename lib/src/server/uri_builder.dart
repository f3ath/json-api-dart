abstract class UriBuilder {
  /// Builds a URI for a resource collection
  Uri collection(String type, {Map<String, String> params = const {}});

  /// Builds a URI for a single resource
  Uri resource(String type, String id, {Map<String, String> params = const {}});

  /// Builds a URI for a related resource
  Uri related(String type, String id, String relationship,
      {Map<String, String> params = const {}});

  /// Builds a URI for a relationship object
  Uri relationship(String type, String id, String relationship,
      {Map<String, String> params = const {}});
}
