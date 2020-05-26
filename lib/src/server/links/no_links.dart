import 'package:json_api/server.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/server/relationship_target.dart';
import 'package:json_api/src/server/resource_target.dart';

class NoLinks implements LinksFactory {
  const NoLinks();

  @override
  Map<String, Link> collection(int total, Pagination pagination) => const {};

  @override
  Map<String, Link> createdResource(ResourceTarget target) => const {};

  @override
  Map<String, Link> relationship(RelationshipTarget target) => const {};

  @override
  Map<String, Link> resource() => const {};

  @override
  Map<String, Link> resourceRelationship(RelationshipTarget target) => const {};
}
