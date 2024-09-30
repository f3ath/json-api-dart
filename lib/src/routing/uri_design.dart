abstract interface class UriDesign {
  Uri collection(String type);

  Uri resource(String type, String id);

  Uri related(String type, String id, String relationship);

  Uri relationship(String type, String id, String relationship);
}
