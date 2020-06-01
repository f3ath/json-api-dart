
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/relationship.dart';

class IncompleteRelationship extends Relationship {
  IncompleteRelationship(
      {Map<String, Link> links = const {}, Map<String, Object> meta = const {}})
      : super(links: links, meta: meta);
}
