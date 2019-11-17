import 'package:json_api/document.dart';

abstract class ClientDocumentFactory {
  Document<ResourceData> makeResourceDocument(Resource resource);

  Document<ToMany> makeToManyDocument(List<Identifier> identifiers);

  Document<ToOne> makeToOneDocument(Identifier identifier);
}
