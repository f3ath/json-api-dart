import 'package:json_api/src/link.dart';
import 'package:json_api/src/resource.dart';
import 'package:json_api/src/routing.dart';
import 'package:json_api/src/validation.dart';

abstract class Document implements Validatable {
  Object toJson();
}

class CollectionDocument implements Document {
  final List<Resource> collection;
  final CollectionRoute route;
  final List<Resource> included;
  Link self;
  Link prev;
  Link next;
  Link first;
  Link last;

  CollectionDocument(this.collection, {this.included = const [], this.route});

  Object toJson() {
    final json = <String, Object>{'data': collection.map((_) => _.toJson()).toList()};
    final links = <String, Object>{
      'self': self?.toJson(),
      'prev': prev?.toJson(),
      'next': next?.toJson(),
      'first': first?.toJson(),
      'last': last?.toJson(),
    }..removeWhere((k, v) => v == null);
    if (links.isNotEmpty) {
      json['links'] = links;
    }
    if (included?.isNotEmpty == true) json['included'] = included.toList();
    return json;
  }

  List<Violation> validate([Naming naming = const StandardNaming()]) {
    return collection.expand((_) => _.validate(naming)).toList();
  }

  void setLinks(LinkFactory link) {
    collection.forEach((_) => _.setLinks(link));
    included.forEach((_) => _.setLinks(link));

    if (route == null) return;

    self = route.link(link);

    final page = route.page;
    if (page == null) return;

    if (page.prev != null) prev = route.replace(page: page.prev).link(link);
    if (page.next != null) next = route.replace(page: page.next).link(link);
    if (page.first != null) first = route.replace(page: page.first).link(link);
    if (page.last != null) last = route.replace(page: page.last).link(link);
  }
}
