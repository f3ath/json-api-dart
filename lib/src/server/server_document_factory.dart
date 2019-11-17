import 'package:json_api/document.dart';
import 'package:json_api/src/document/json_api_error.dart';
import 'package:json_api/src/target.dart';

abstract class ServerDocumentFactory {
  Document makeErrorDocument(Iterable<JsonApiError> errors);

  Document<ResourceCollectionData> makeCollectionDocument(
      Iterable<Resource> collection,
      {Uri self,
      Iterable<Resource> included,
      int total});

  Document<ResourceData> makeResourceDocument(Resource resource,
      {Uri self, Iterable<Resource> included});

  Document<ResourceData> makeRelatedResourceDocument(Resource resource,
      {Uri self});

  Document<ResourceCollectionData> makeRelatedCollectionDocument(
      Iterable<Resource> collection,
      {Uri self,
      int total});

  Document<ToOne> makeToOneDocument(Identifier identifier,
      {RelationshipTarget target, Uri self});

  Document<ToMany> makeToManyDocument(Iterable<Identifier> collection,
      {RelationshipTarget target, Uri self});

  Document makeMetaDocument(Map<String, Object> meta);
}
