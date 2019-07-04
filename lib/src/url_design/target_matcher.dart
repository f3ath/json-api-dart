/// Determines if a given URI matches a specific target
abstract class TargetMatcher {
  /// Matches the target of the [uri]. If the target can be determined,
  /// the corresponding callback will be called with the target parameters.
  void match(Uri uri,
      {onCollection(String type),
      onResource(String type, String id),
      onRelationship(String type, String id, String relationship),
      onRelated(String type, String id, String relationship)});
}
