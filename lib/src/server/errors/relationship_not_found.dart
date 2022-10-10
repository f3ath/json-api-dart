/// A relationship is not found on the server.
class RelationshipNotFound implements Exception {
  RelationshipNotFound(this.type, this.id, this.relationship);

  final String type;
  final String id;
  final String relationship;
}
