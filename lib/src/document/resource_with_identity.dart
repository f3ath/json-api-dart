import 'package:json_api/src/document/identity.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/many.dart';
import 'package:json_api/src/document/one.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';

class ResourceWithIdentity extends Resource with Identity {
  ResourceWithIdentity(this.type, this.id,
      {Map<String, Link> links = const {},
      Map<String, Object> meta = const {},
      Map<String, Object> attributes = const {},
      Map<String, Relationship> relationships = const {}})
      : links = Map.unmodifiable(links ?? {}),
        super(type,
            attributes: attributes, relationships: relationships, meta: meta);

  static ResourceWithIdentity fromJson(dynamic json) {
    if (json is Map) {
      return ResourceWithIdentity(
          Maybe(json['type'])
              .cast<String>()
              .orThrow(() => ArgumentError('Invalid type')),
          Maybe(json['id'])
              .cast<String>()
              .orThrow(() => ArgumentError('Invalid id')),
          attributes: Maybe(json['attributes']).cast<Map>().or(const {}),
          relationships: Maybe(json['relationships'])
              .cast<Map>()
              .map((t) => t.map((key, value) =>
                  MapEntry(key.toString(), Relationship.fromJson(value))))
              .orGet(() => {}),
          links: Link.mapFromJson(json['links']),
          meta: json['meta']);
    }
    throw FormatException('A JSON:API resource must be a JSON object');
  }

  @override
  final String type;
  @override
  final String id;
  final Map<String, Link> links;

  Maybe<Many> many(String key) => Maybe(relationships[key]).cast<Many>();

  Maybe<One> one(String key) => Maybe(relationships[key]).cast<One>();

  @override
  Map<String, Object> toJson() => {
        'id': id,
        ...super.toJson(),
        if (links.isNotEmpty) 'links': links,
      };
}
