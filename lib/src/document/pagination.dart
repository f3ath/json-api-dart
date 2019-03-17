import 'package:json_api/src/document/link.dart';

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

  Map<String, Link> toLinks() => {
        'prev': prev,
        'next': next,
        'first': first,
        'last': last
      }..removeWhere((_, v) => v == null);

  static Pagination fromLinks(Map<String, Link> links) => Pagination(
        first: links['first'],
        last: links['last'],
        next: links['next'],
        prev: links['prev'],
      );
}
