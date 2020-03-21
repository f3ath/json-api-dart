import 'package:json_api/document.dart';
import 'package:json_api/src/server/pagination.dart';

/// Creates `links` objects for JSON:API documents
abstract class LinksFactory {
  /// Links for a resource object (primary or related)
  Map<String, Link> resource(String type, String id);

  /// Links for a collection (primary or related)
  Map<String, Link> collection(int total, Pagination pagination);

  /// Links for a newly created resource
  Map<String, Link> createdResource(String type, String id);

  /// Links for a standalone relationship
  Map<String, Link> relationship(String type, String id, String relationship);

  /// Links for a relationship inside a resource
  Map<String, Link> resourceRelationship(
      String type, String id, String relationship);
}
