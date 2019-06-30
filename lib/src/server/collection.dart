/// A collection of elements (e.g. resources) returned by the server.
class Collection<T> {
  final Iterable<T> elements;
  final int total;

  Collection(this.elements, {this.total});
}
