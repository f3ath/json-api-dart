import 'package:json_api/document.dart';
import 'package:json_api/src/server/collection.dart';
import 'package:json_api/src/server/request_target.dart';

/// The Document builder is used by JsonApiServer. It abstracts the process
/// of building response documents and is responsible for such aspects as
///  adding `meta` and `jsonapi` attributes and generating links
abstract class DocumentBuilder {
  Document<ResourceCollectionData> collection(
      Collection<Resource> collection, CollectionTarget target, Uri self,
      {Iterable<Resource> included});

  Document<ResourceData> resource(
      Resource resource, ResourceTarget target, Uri self,
      {Iterable<Resource> included});

  Document<ResourceCollectionData> relatedCollection(
      Collection<Resource> resources, RelatedTarget target, Uri self,
      {Iterable<Resource> included});

  Document<ResourceData> relatedResource(
      Resource resource, RelatedTarget target, Uri self,
      {Iterable<Resource> included});

  Document<ToMany> toMany(
      Iterable<Identifier> collection, RelationshipTarget target, Uri self);

  Document<ToOne> toOne(
      Identifier identifier, RelationshipTarget target, Uri self);

  Document meta(Map<String, Object> meta);

  Document error(Iterable<JsonApiError> errors);
}
