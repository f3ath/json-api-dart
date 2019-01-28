import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/document/validation.dart';

abstract class Document implements Validatable {}

class CollectionDocument implements Document {
  final collection = <Resource>[];
  final included = <Resource>[];
  final Link self;
  final PaginationLinks pagination;

  CollectionDocument(List<Resource> collection,
      {List<Resource> included, this.self, this.pagination}) {
    this.collection.addAll(collection ?? []);
    this.included.addAll(included ?? []);
  }

  toJson() {
    final json = <String, Object>{
      'data': collection.map((_) => _.toJson()).toList()
    };

    final links = {'self': self}
      ..addAll(pagination.asMap)
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
}
