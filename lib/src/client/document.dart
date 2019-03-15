import 'package:json_api/src/document/error_object.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/nullable.dart';

abstract class PrimaryData {
  Map<String, Link> get links;

  toJson();
}

typedef Data DataParser<Data extends PrimaryData>(Object json);

class Document<D extends PrimaryData> {
  final Link self;
  final D data;
  final errors = <ErrorObject>[];
  final meta = <String, Object>{};
  final bool isError;
  final included = <ResourceObject>[];

  Document(D this.data, {Map<String, Object> meta, this.self})
      : isError = false {
    this.meta.addAll(meta ?? {});
  }

  Document.error(Iterable<ErrorObject> errors,
      {Map<String, Object> meta, this.self})
      : data = null,
        isError = true {
    this.errors.addAll(errors ?? {});
    this.meta.addAll(meta ?? {});
  }

  Document.empty(Map<String, Object> meta, {this.self})
      : data = null,
        isError = false {
    this.meta.addAll(meta ?? {});
  }

  static Document<Data> fromJson<Data extends PrimaryData>(
      Object json, DataParser<Data> dataParser) {
    if (json is Map) {
      if (json.containsKey('errors')) {
        final errors = json['errors'];
        if (errors is List) {
          return Document.error(errors.map(ErrorObject.fromJson));
        }
      }
      if (json.containsKey('data')) {
        return Document(dataParser(json['data']));
      }
      if (json.containsKey('meta')) {
        final meta = json['meta'];
        if (meta is Map) {
          return Document.empty(meta);
        }
      }
    }
  }

  toJson() {
    return {'data': data};
  }
}

class Pagination {
  final Link prev;
  final Link next;
  final Link first;
  final Link last;

  Pagination({this.last, this.first, this.prev, this.next});

  const Pagination.empty()
      : prev = null,
        next = null,
        first = null,
        last = null;

  get links => {'prev': prev, 'next': next, 'first': first, 'last': last};

  static Pagination fromJson(Map json) => Pagination.empty();
}

class Collection<T> {
  final elements = <T>[];
  final Pagination pagination;

  Collection(Iterable<T> elements, this.pagination) {
    this.elements.addAll(elements);
  }
}

class ResourceObject implements PrimaryData {
  final String type;
  final String id;
  final attributes = <String, Object>{};
  final relationships = <String, Relationship>{};

  ResourceObject(this.type, this.id,
      {Map<String, Object> attributes,
      Map<String, Relationship> relationships}) {
    this.attributes.addAll(attributes ?? {});
    this.relationships.addAll(relationships ?? {});
  }

  Map<String, Link> get links => {};

  static ResourceObject fromJson(Object json) {
    if (json is Map) {
      return ResourceObject(json['type'], json['id'],
          attributes: json['attributes'],
          relationships: Relationship.parseMap(json['relationships'] ?? {}));
    }
    throw 'Can not parse ResourceObject from $json';
  }

  static ResourceObject fromResource(Resource resource) {
    final relationships = <String, Relationship>{};
    resource.toOne.forEach((k, v) => relationships[k] =
        nullable((_) => Relationship(IdentifierObject.fromIdentifier(_)))(v));
    resource.toMany.forEach((k, v) => relationships[k] = Relationship(
        IdentifierCollection(
            v.map(nullable(IdentifierObject.fromIdentifier)))));

    return ResourceObject(resource.type, resource.id,
        attributes: resource.attributes, relationships: relationships);
  }

  toJson() {
    return {
      'type': type,
      'id': id,
      'attributes': attributes,
      'relationships': relationships
    };
  }

  Resource toResource() {
    final toOne = <String, Identifier>{};
    final toMany = <String, List<Identifier>>{};
    relationships.forEach((name, rel) {
      final data = rel.data;
      // TODO: detect incomplete relationships
      if (data is IdentifierObject) {
        toOne[name] = data.toIdentifier();
      } else if (data is IdentifierCollection) {
        toMany[name] = data.toIdentifiers();
      }
    });

    return Resource(type, id,
        attributes: attributes, toOne: toOne, toMany: toMany);
  }
}

class ResourceCollection extends Collection<ResourceObject>
    implements PrimaryData {
  ResourceCollection(Iterable<ResourceObject> elements,
      {Pagination pagination = const Pagination.empty()})
      : super(elements, pagination);

  @override
  Map<String, Link> get links => {};

  static ResourceCollection fromJson(Object json) {
    if (json is List) {
      return ResourceCollection(json.map(ResourceObject.fromJson));
    }
    throw 'Can not parse ResourceCollection from $json';
  }

  @override
  toJson() {
    return {'data': elements.toList()};
  }
}

class Relationship<D extends RelationshipData> extends Document<D> {
  Relationship(D data) : super(data);

  static Relationship fromJson(Object json) {
    if (json is Map) {
      return Relationship(RelationshipData.fromJson(json['data']));
    }
    throw 'Can not parse Relationship from $json';
  }

  static Map<String, Relationship> parseMap(Map map) =>
      map.map((k, v) => MapEntry(k, fromJson(v)));
}

abstract class RelationshipData implements PrimaryData {
  static RelationshipData fromJson(Object json) {
    if (json is Map) return IdentifierObject.fromJson(json);
    if (json is List) return IdentifierCollection.fromJson(json);
    throw 'Can not parse RelationshipData from $json';
  }
}

class IdentifierObject implements RelationshipData {
  final Link related;
  final String type;
  final String id;

  IdentifierObject(this.type, this.id, {this.related});

  @override
  Map<String, Link> get links => {'related': related};

  static IdentifierObject fromJson(Object json) {
    if (json is Map) {
      return IdentifierObject(json['type'], json['id']);
    }
    throw 'Can not parse IdentifierObject from $json';
  }

  @override
  toJson() {
    return {'type': type, 'id': id};
  }

  Identifier toIdentifier() => Identifier(type, id);

  static IdentifierObject fromIdentifier(Identifier id) =>
      IdentifierObject(id.type, id.id);
}

class IdentifierCollection extends Collection<IdentifierObject>
    implements RelationshipData {
  final Link related;

  IdentifierCollection(Iterable<IdentifierObject> elements,
      {Pagination pagination = const Pagination.empty(), this.related})
      : super(elements, pagination);

  @override
  Map<String, Link> get links => {'related': related};

  static IdentifierCollection fromJson(Object json) {
    if (json is List) {
      return IdentifierCollection(json.map(IdentifierObject.fromJson));
    }
  }

  @override
  toJson() {
    return elements.toList();
  }

  List<Identifier> toIdentifiers() =>
      elements.map((_) => _.toIdentifier()).toList();
}

class Identifier {
  /// Resource type
  final String type;

  /// Resource id
  final String id;

  Identifier(this.type, this.id) {
    ArgumentError.checkNotNull(id, 'id');
    ArgumentError.checkNotNull(type, 'type');
  }
}

class Resource {
  /// Resource type
  final String type;

  /// Resource id
  ///
  /// May be null for resources to be created on the cars_server
  final String id;

  /// Resource attributes
  final attributes = <String, Object>{};

  /// to-one relationships
  final toOne = <String, Identifier>{};

  /// to-many relationships
  final toMany = <String, List<Identifier>>{};

  /// True if the Resource has a non-empty id
  bool get hasId => id != null && id.isNotEmpty;

  Resource(this.type, this.id,
      {Map<String, Object> attributes,
      Map<String, Identifier> toOne,
      Map<String, List<Identifier>> toMany}) {
    ArgumentError.checkNotNull(type, 'type');
    this.attributes.addAll(attributes ?? {});
    this.toOne.addAll(toOne ?? {});
    this.toMany.addAll(toMany ?? {});
  }
}

class NoData implements PrimaryData {
  const NoData();

  @override
  // TODO: implement links
  Map<String, Link> get links => {};

  @override
  toJson() {
    // TODO: implement toJson
    return null;
  }
}
