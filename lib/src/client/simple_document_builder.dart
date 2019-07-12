import 'package:json_api/document.dart';

abstract class SimpleDocumentBuilder {
  Document<ResourceData> resourceDocument(Resource resource);

  Document<ToMany> toManyDocument(List<Identifier> identifiers);

  Document<ToOne> toOneDocument(Identifier identifier);
}
