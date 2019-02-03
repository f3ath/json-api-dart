import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/validation.dart';

abstract class Relationship extends Validatable {
  Object get data;

  final Link self;
  final Link related;

  Relationship({this.self, this.related});

  Relationship replace({Link self, Link related});

  Future<Document> fetchRelated(JsonApiClient client);

  Map<String, Object> toJson() {
    final json = {'data': data};
    final links = {'self': self, 'related': related}
      ..removeWhere((k, v) => v == null);
    if (links.isNotEmpty) {
      json['links'] = links;
    }
    return json;
  }

  static Map<String, Relationship> parseMap(Map map) =>
      map.map((k, r) => MapEntry(k, Relationship.fromJson(r)));

  factory Relationship.fromJson(Object json) {
    if (json is Map) {
      final links = Link.parseMap(json['links'] ?? {});
      final data = json['data'];
      if (data is List) {
        return ToMany(data.map((_) => Identifier.fromJson(_)),
            self: links['self'], related: links['related']);
      }
      return ToOne(Identifier.fromJson(json['data']),
          self: links['self'], related: links['related']);
    }
    throw 'Parse error';
  }
}

class ToMany extends Relationship {
  final identifiers = <Identifier>[];

  ToMany(Iterable<Identifier> identifiers, {Link self, Link related})
      : super(self: self, related: related) {
    ArgumentError.checkNotNull(identifiers, 'identifiers');
    this.identifiers.addAll(identifiers);
  }

  Object get data => identifiers.toList();

  validate(Naming naming) => identifiers
      .toList()
      .asMap()
      .entries
      .expand((_) => _.value.validate(Prefixed(naming, '/${_.key}')))
      .toList();

  ToMany replace({Link self, Link related}) => ToMany(this.identifiers,
      self: self ?? this.self, related: related ?? this.related);

  Future<CollectionDocument> fetchRelated(JsonApiClient client) =>
      client.fetchCollection(related.uri);
}

class ToOne extends Relationship {
  final Identifier identifier;

  ToOne(this.identifier, {Link self, Link related})
      : super(self: self, related: related) {}

  Object get data => identifier;

  validate(Naming naming) => identifier.validate(naming);

  ToOne replace({Link self, Link related}) => ToOne(this.identifier,
      self: self ?? this.self, related: related ?? this.related);

  Future<ResourceDocument> fetchRelated(JsonApiClient client) =>
      client.fetchResource(related.uri);
}
