import 'package:json_api/src/server/collection.dart';
import 'package:json_api/src/server/request_target.dart';
import 'package:json_api_document/document.dart';

/// The Document builder is used by JsonApiServer. It abstracts the process
/// of building response documents and is responsible for such aspects as
///  adding `meta` and `jsonapi` attributes and generating links
abstract class DocumentBuilder {
  /// A collection of (primary) resources
  Document<ResourceCollectionData> collection(
      Collection<Resource> collection, CollectionTarget target, Uri self,
      {Iterable<Resource> included});

  /// A single (primary) resource
  Document<ResourceData> resource(
      Resource resource, ResourceTarget target, Uri self,
      {Iterable<Resource> included});

  /// A collection of related resources
  Document<ResourceCollectionData> relatedCollection(
      Collection<Resource> resources, RelatedTarget target, Uri self,
      {Iterable<Resource> included});

  /// A single related resource
  Document<ResourceData> relatedResource(
      Resource resource, RelatedTarget target, Uri self,
      {Iterable<Resource> included});

  /// A to-many relationship
  Document<ToMany> toMany(
      Iterable<Identifier> collection, RelationshipTarget target, Uri self);

  /// A to-one relationship
  Document<ToOne> toOne(
      Identifier identifier, RelationshipTarget target, Uri self);

  /// A document containing just a meta member
  Document meta(Map<String, Object> meta);

  /// A document containing a list of errors
  Document error(Iterable<JsonApiError> errors);
}
