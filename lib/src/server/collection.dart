import 'package:json_api/src/server/contracts/page.dart';

class Collection<T> {
  final Iterable<T> elements;
  final Page page;

  Collection(this.elements, {this.page});
}
