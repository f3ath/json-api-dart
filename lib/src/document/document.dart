import 'package:json_api/client.dart';
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
      if (data == null) {
        return ResourceDocument(null);
      }
    }
    throw 'Can not parse ResourceDocument from $json';
  }
}

class CollectionDocument implements Document {
  final resources = <Resource>[];
  final included = <Resource>[];
  final Link self;
  final PaginationLinks pagination;

  CollectionDocument(Iterable<Resource> collection,
      {Iterable<Resource> included, this.self, this.pagination}) {
    this.resources.addAll(collection ?? []);
    this.included.addAll(included ?? []);
  }

  Link get first => pagination.first;

  Link get last => pagination.last;

  Link get prev => pagination.prev;

  Link get next => pagination.next;

  toJson() {
    final json = <String, Object>{'data': resources};

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
    return resources.expand((_) => _.validate(naming)).toList();
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
    throw 'Can not parse CollectionDocument from $json';
  }

  Future<CollectionDocument> fetchNext(Client client) =>
      pagination.fetch('next', client);

  Future<CollectionDocument> fetchPrev(Client client) =>
      pagination.fetch('prev', client);

  Future<CollectionDocument> fetchFirst(Client client) =>
      pagination.fetch('first', client);

  Future<CollectionDocument> fetchLast(Client client) =>
      pagination.fetch('last', client);
}

class PaginationLinks {
  final Link first;
  final Link last;
  final Link prev;
  final Link next;

  PaginationLinks({this.next, this.first, this.last, this.prev});

  PaginationLinks.fromMap(Map<String, Link> links)
      : this(
            first: links['first'],
            last: links['last'],
            next: links['next'],
            prev: links['prev']);

  Map<String, Link> get asMap =>
      {'first': first, 'last': last, 'prev': prev, 'next': next};

  Future<CollectionDocument> fetch(String name, Client client) async {
    final page = asMap[name];
    if (page == null) throw StateError('Page $name is not set');
    final response = await client.fetchCollection(page.uri);
    return response.document;
  }
}
