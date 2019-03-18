import 'package:json_api/document.dart';
import 'package:json_api/src/server/contracts/page.dart';

/// The Document builder is used by JsonApiServer. It abstracts the process
/// of building response documents and is responsible for such aspects as
///  adding `meta` and `jsonapi` attributes and generating links
abstract class DocumentBuilder {
  /// Given the [collection] of type [type] return a document.
  /// If the collection is paginated, the [page] parameter will contain the
  /// current page details.
  Document<ResourceCollectionData> collection(
      Iterable<Resource> collection, String type, Uri self,
      {Page page, Iterable<Resource> included});

  Document<ResourceCollectionData> relatedCollection(
      Iterable<Resource> collection,
      String type,
      String id,
      String relationship,
      Uri self,
      {Page page,
      Iterable<Resource> included});

  Document<ResourceData> resource(
      Resource resource, String type, String id, Uri self,
      {Iterable<Resource> included});

  Document<ResourceData> relatedResource(
      Resource resource, String type, String id, String relationship, Uri self,
      {Iterable<Resource> included});

  Document<ToMany> toMany(Iterable<Identifier> collection, String type,
      String id, String relationship, Uri self);

  Document<ToOne> toOne(Identifier identifier, String type, String id,
      String relationship, Uri self);

  Document meta(Map<String, Object> meta);

  Document error(Iterable<JsonApiError> errors);
}
