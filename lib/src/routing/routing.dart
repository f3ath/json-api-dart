import 'package:json_api/src/routing/collection_uri.dart';
import 'package:json_api/src/routing/related_uri.dart';
import 'package:json_api/src/routing/relationship_uri.dart';
import 'package:json_api/src/routing/resource_uri.dart';

/// Routing represents the design of the 4 kinds of URLs:
/// - collection URL (e.g. /books)
/// - resource URL (e.g. /books/13)
/// - related resource/collection URL (e.g. /books/123/author)
/// - relationship URL (e.g. /books/123/relationship/author)
abstract class Routing {
  CollectionUri get collection;

  ResourceUri get resource;

  RelatedUri get related;

  RelationshipUri get relationship;
}
