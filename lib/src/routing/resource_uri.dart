abstract class ResourceUri {
  Uri uri(String type, String id);

  bool match(Uri uri, void Function(String type, String id) onMatch);
}
