import 'package:json_api/resource.dart';
import 'package:json_api/src/client/client.dart';
import 'package:json_api/src/transport/document.dart';
import 'package:json_api/src/transport/link.dart';
import 'package:json_api/src/transport/resource_envelope.dart';

class CollectionDocument implements Document {
  final List<ResourceEnvelope> collection;
  final List<ResourceEnvelope> included;

  final Link self;
  final Pagination pagination;

  CollectionDocument(List<ResourceEnvelope> collection,
      {List<ResourceEnvelope> included, this.self, this.pagination})
      : collection = List.unmodifiable(collection),
        included = List.unmodifiable(included ?? []);

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

  static CollectionDocument fromJson(Object json) {
    if (json is Map) {
      final data = json['data'];
      if (data is List) {
        final links = Link.parseMap(json['links'] ?? {});
        return CollectionDocument(data.map(ResourceEnvelope.fromJson).toList(),
            self: links['self'], pagination: Pagination.fromMap(links));
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

class Pagination {
  final Link first;
  final Link last;
  final Link prev;
  final Link next;

  Pagination({this.next, this.first, this.last, this.prev});

  Pagination.fromMap(Map<String, Link> links)
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
