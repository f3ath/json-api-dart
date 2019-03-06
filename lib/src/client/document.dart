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
        return Document(dataParser(json));
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

  ResourceObject(this.type, this.id, {Map<String, Object> attributes}) {
    this.attributes.addAll(attributes ?? {});
  }

  Map<String, Link> get links => {};

  static ResourceObject fromJson(Object json) {
    if (json is Map) {
      return fromData(json['data']);
    }
    throw 'Can not parse ResourceObject from $json';
  }

  static ResourceObject fromData(Object data) {
    if (data is Map) {
      return ResourceObject(data['type'], data['id'],
          attributes: data['attributes']);
    }
    throw 'Can not parse ResourceObject from $data';
  }

  static ResourceObject fromResource(Resource resource) {
    return ResourceObject(resource.type, resource.id,
        attributes: resource.attributes);
  }

  toJson() {
    return {'type': type, 'id': id, 'attributes': attributes};
  }
}

class ResourceCollection extends Collection<ResourceObject>
    implements PrimaryData {
  ResourceCollection(Iterable<ResourceObject> elements, Pagination pagination)
      : super(elements, pagination);

  @override
  Map<String, Link> get links => {};

  static ResourceCollection fromJson(Object json) {
    if (json is Map) {
      final data = json['data'];
      if (data is List) {
        return ResourceCollection(
            data.map(ResourceObject.fromData), Pagination.empty());
      }
    }
    throw 'Can not parse ResourceCollection from $json';
  }

  @override
  toJson() {
    return {'data': elements.toList()};
  }
}

abstract class Relationship extends PrimaryData {
  static Relationship fromJson(Object json) {
    if (json is Map) {
      final data = json['data'];
      if (data is Map) return IdentifierObject.fromData(data);
      if (data is List) return IdentifierCollection.fromData(data);
    }
  }
}

class IdentifierObject implements Relationship {
  final Link related;
  final String type;
  final String id;

  IdentifierObject(this.type, this.id, {this.related});

  @override
  Map<String, Link> get links => {'related': related};

  static IdentifierObject fromJson(Object json) {
    if (json is Map) {
      return nullable(fromData)(json['data']);
    }
  }

  static IdentifierObject fromData(Object data) {
    if (data is Map) {
      return IdentifierObject(data['type'], data['id']);
    }
  }

  @override
  toJson() {
    return {'type': type, 'id': id};
  }
}

class IdentifierCollection extends Collection<IdentifierObject>
    implements Relationship {
  final Link related;

  IdentifierCollection(
      Iterable<IdentifierObject> elements, Pagination pagination,
      {this.related})
      : super(elements, pagination);

  @override
  Map<String, Link> get links => {'related': related};

  static IdentifierCollection fromJson(Object json) {
    if (json is Map) {
      final data = json['data'];
      if (data is List) {
        return IdentifierCollection(
            data.map(IdentifierObject.fromData), Pagination.empty());
      }
    }
  }

  static IdentifierCollection fromData(Object data) {
    if (data is List) {
      return IdentifierCollection(
          data.map(IdentifierObject.fromData), Pagination.empty());
    }
  }

  @override
  toJson() {
    return {'data': elements.toList()};
  }
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
