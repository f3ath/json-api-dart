/// A resource is not found on the server.
class ResourceNotFound implements Exception {
  ResourceNotFound(this.type, this.id);

  final String type;
  final String id;
}
