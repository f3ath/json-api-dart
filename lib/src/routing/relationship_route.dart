abstract class RelationshipRoute {
  Uri uri(String type, String id, String relationship);

  bool match(Uri uri,
      void Function(String type, String id, String relationship) onMatch);
}
