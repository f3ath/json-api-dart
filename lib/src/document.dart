import 'package:json_api/src/link.dart';
import 'package:json_api/src/resource.dart';
import 'package:json_api/src/routing.dart';
import 'package:json_api/src/validation.dart';

class CollectionDocument implements Validatable {
  final Iterable<Resource> collection;
  final CollectionRoute route;
  final List<Resource> included;
  Link self;
  Link prev;
  Link next;
  Link first;
  Link last;

  CollectionDocument(this.collection, {this.included, this.route});

  Object toJson() {
    final json = <String, Object>{'data': collection};
    final links = <String, Link>{
      'self': self,
      'pref': prev,
      'next': next,
      'first': first,
      'last': last,
    }..removeWhere((k, v) => v == null);
    if (links.isNotEmpty) {
      json['links'] = links;
    }
    if (included?.isNotEmpty == true) json['included'] = included.toList();
    return json;
  }

  Iterable<Violation> validate([Naming naming = const StandardNaming()]) {
    return collection.expand((_) => _.validate(naming));
  }

  void setLinks(LinkFactory link) {
    self = route?.link(link);
    prev = route?.prevPage?.link(link);
    next = route?.nextPage?.link(link);
    first = route?.firstPage?.link(link);
    last = route?.lastPage?.link(link);
    collection.forEach((_) => _.setLinks(link));
    included.forEach((_) => _.setLinks(link));
  }
}
