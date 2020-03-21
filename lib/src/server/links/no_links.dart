import 'package:json_api/server.dart';
import 'package:json_api/src/document/link.dart';

class NoLinks implements LinksFactory {
  const NoLinks();

  @override
  Map<String, Link> collection(int total, Pagination pagination) => const {};

  @override
  Map<String, Link> createdResource(String type, String id) => const {};

  @override
  Map<String, Link> relationship(String type, String id, String relationship) =>
      const {};

  @override
  Map<String, Link> resource(String type, String id) => const {};

  @override
  Map<String, Link> resourceRelationship(
          String type, String id, String relationship) =>
      const {};
}
