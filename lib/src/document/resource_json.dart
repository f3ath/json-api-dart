import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/identifier_json.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/pagination.dart';
import 'package:json_api/src/document/primary_data.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/nullable.dart';

/// [ResourceJson] is a JSON representation of a [Resource].
///
/// It carries all JSON-related logic and the Meta-data.
/// In a JSON:API Document it can be the value of the `data` member (a `data`
/// member element in case of a collection) or a member of the `included`
/// resource collection.
///
/// More on this: https://jsonapi.org/format/#document-resource-objects
class ResourceJson {
  final String type;
  final String id;
  final Link self;
  final attributes = <String, Object>{};
  final relationships = <String, Relationship>{};

  ResourceJson(this.type, this.id,
      {Map<String, Object> attributes,
      Map<String, Relationship> relationships,
      this.self}) {
    this.attributes.addAll(attributes ?? {});
    this.relationships.addAll(relationships ?? {});
  }

  static ResourceJson fromResource(Resource resource) {
    final relationships = <String, Relationship>{}
      ..addAll(resource.toOne.map((k, v) =>
          MapEntry(k, ToOne(nullable(IdentifierJson.fromIdentifier)(v)))))
      ..addAll(resource.toMany.map(
          (k, v) => MapEntry(k, ToMany(v.map(IdentifierJson.fromIdentifier)))));

    return ResourceJson(resource.type, resource.id,
        attributes: resource.attributes, relationships: relationships);
  }

  /// Returns the JSON object to be used in the `data` or `included` members
  /// of a JSON:API Document
  Map<String, Object> toJson() {
    final json = <String, Object>{'type': type, 'id': id};
    if (attributes.isNotEmpty) {
      json['attributes'] = attributes;
    }
    if (relationships.isNotEmpty) {
      json['relationships'] = relationships;
    }
    if (self != null) {
      json['links'] = {'self': self};
    }
    return json;
  }

  /// Converts to [Resource] if possible. The standard allows relationships
  /// without `data` member. In this case the original [Resource] can not be
  /// recovered and this method will throw a [StateError].
  ///
  /// TODO: we probably need `isIncomplete` flag to check for this.
  Resource toResource() {
    final toOne = <String, Identifier>{};
    final toMany = <String, List<Identifier>>{};
    final incomplete = <String, Relationship>{};
    relationships.forEach((name, rel) {
      if (rel is ToOne) {
        toOne[name] = rel.toIdentifier();
      } else if (rel is ToMany) {
        toMany[name] = rel.toIdentifiers().toList();
      } else {
        incomplete[name] = rel;
      }
    });

    if (incomplete.isNotEmpty) {
      throw StateError('Can not convert to resource'
          ' due to incomplete relationships data: ${incomplete.keys}');
    }

    return Resource(type, id,
        attributes: attributes, toOne: toOne, toMany: toMany);
  }
}

/// Represents a single resource or a single related resource of a to-one relationship\\\\\\\\
class ResourceData extends PrimaryData {
  final ResourceJson resourceJson;

  /// For Compound Documents this member contains the included resources
  final List<ResourceJson> included;

  ResourceData(this.resourceJson, {Link self, Iterable<ResourceJson> included})
      : this.included =
            (included == null || included.isEmpty ? null : List.from(included)),
        super(self: self);

  @override
  Map<String, Object> toJson() {
    final json = <String, Object>{'data': resourceJson};
    if (included != null && included.isNotEmpty) {
      json['included'] = included;
    }

    final links = toLinks();
    if (links.isNotEmpty) json['links'] = links;
    return json;
  }

  Resource toResource() => resourceJson.toResource();
}

/// Represents a resource collection or a collection of related resources of a to-many relationship
class ResourceCollectionData extends PrimaryData {
  final collection = <ResourceJson>[];
  final Pagination pagination;

  /// For Compound Documents this member contains the included resources
  final List<ResourceJson> included;

  ResourceCollectionData(Iterable<ResourceJson> collection,
      {Link self,
      Iterable<ResourceJson> included,
      this.pagination = const Pagination.empty()})
      : this.included =
            (included == null || included.isEmpty ? null : List.from(included)),
        super(self: self) {
    this.collection.addAll(collection);
  }

  @override
  Map<String, Object> toJson() {
    final json = <String, Object>{'data': collection};
    if (included != null && included.isNotEmpty) {
      json['included'] = included;
    }

    final links = toLinks()..addAll(pagination.toLinks());
    if (links.isNotEmpty) json['links'] = links;
    return json;
  }
}
