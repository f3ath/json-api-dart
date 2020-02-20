abstract class RouteMatcher {
  bool matchCollection(Uri uri, void Function(String type) onMatch);

  bool matchResource(Uri uri, void Function(String type, String id) onMatch);

  bool matchRelated(Uri uri,
      void Function(String type, String id, String relationship) onMatch);

  bool matchRelationship(Uri uri,
      void Function(String type, String id, String relationship) onMatch);
}
