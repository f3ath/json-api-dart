abstract class CollectionRoute {
  Uri uri(String type);

  bool match(Uri uri, void Function(String type) onMatch);
}
