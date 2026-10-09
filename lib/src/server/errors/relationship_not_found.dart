/// A relationship is not found on the server.
class RelationshipNotFound(
  final String type,
  final String id,
  final String relationship,
) implements Exception;
