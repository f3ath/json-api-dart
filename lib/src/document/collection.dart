//class Pagination {
//  final Link prev;
//  final Link next;
//  final Link first;
//  final Link last;
//
//  Pagination({this.last, this.first, this.prev, this.next});
//
//  const Pagination.empty()
//      : prev = null,
//        next = null,
//        first = null,
//        last = null;
//
//  get links => {'prev': prev, 'next': next, 'first': first, 'last': last};
//
//  static Pagination fromJson(Map json) => Pagination.empty();
//
//  Pagination.fromMap(Map<String, Link> links)
//      : this(
//            first: links['first'],
//            last: links['last'],
//            next: links['next'],
//            prev: links['prev']);
//}

class Collection<T> {
  final elements = <T>[];

  Collection(Iterable<T> elements) {
    this.elements.addAll(elements);
  }
}
