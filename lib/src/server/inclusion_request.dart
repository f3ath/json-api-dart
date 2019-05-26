import 'package:json_api/src/server/uri_manipulation.dart';

class InclusionRequest with UriManipulation {
  static const delimiter = ',';
  static const key = 'include';

  final relationships = <RelationshipPath>[];

  InclusionRequest(Iterable<RelationshipPath> relationships) {
    this.relationships.addAll(relationships);
  }

  static InclusionRequest fromQuery(Map<String, List<String>> query) =>
      InclusionRequest(query[key]
          .expand((_) => _.split(delimiter))
          .map(RelationshipPath.fromString));

  Map<String, List<String>> get query => {
        key: [relationships.map((_) => _.toString()).join(delimiter)]
      };
}

class RelationshipPath {
  static const delimiter = '.';
  final elements = <String>[];

  RelationshipPath(Iterable<String> elements) {
    this.elements.addAll(elements);
  }

  static RelationshipPath fromString(String s) =>
      RelationshipPath(s.split(delimiter));

  @override
  String toString() => elements.join(delimiter);
}
