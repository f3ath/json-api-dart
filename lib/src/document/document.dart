import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/document/validation.dart';

abstract class Document implements Validatable {}

class ResourceDocument implements Document {
  final Resource resource;
  final included = <Resource>[];
  final Link self;

  ResourceDocument(this.resource, {Iterable<Resource> included, this.self}) {
    this.included.addAll(included ?? []);
  }

  toJson() {
    final json = <String, Object>{'data': resource};

    final links = {'self': self}..removeWhere((k, v) => v == null);
    if (links.isNotEmpty) {
      json['links'] = links;
    }
    if (included.isNotEmpty) json['included'] = included.toList();
    return json;
  }

  List<Violation> validate(Naming naming) {
    return resource.validate(naming);
  }

  factory ResourceDocument.fromJson(Object json) {
    if (json is Map) {
      final data = json['data'];
      if (data is Map) {
        return ResourceDocument(Resource.fromJson(data));
      }
    }
    throw 'Parse error';
  }
}

class CollectionDocument implements Document {
  final collection = <Resource>[];
  final included = <Resource>[];
  final Link self;
  final PaginationLinks pagination;

  CollectionDocument(Iterable<Resource> collection,
      {Iterable<Resource> included, this.self, this.pagination}) {
    this.collection.addAll(collection ?? []);
    this.included.addAll(included ?? []);
  }

  Link get first => pagination.first;

  Link get last => pagination.last;

  Link get prev => pagination.prev;

  Link get next => pagination.next;

  toJson() {
    final json = <String, Object>{'data': collection};

    final links = {'self': self}
      ..addAll(pagination?.asMap ?? {})
      ..removeWhere((k, v) => v == null);
    if (links.isNotEmpty) {
      json['links'] = links;
    }
    if (included?.isNotEmpty == true) json['included'] = included.toList();
    return json;
  }

  List<Violation> validate(Naming naming) {
    return collection.expand((_) => _.validate(naming)).toList();
  }

  factory CollectionDocument.fromJson(Object json) {
    if (json is Map) {
      final data = json['data'];
      if (data is List) {
        final links = Link.parseMap(json['links'] ?? {});
        return CollectionDocument(data.map((_) => Resource.fromJson(_)),
            self: links['self'], pagination: PaginationLinks.fromMap(links));
      }
    }
    throw 'Parse error';
  }
}