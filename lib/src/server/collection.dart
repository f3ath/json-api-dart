/// A collection of elements (e.g. resources) returned by the server.
class Collection<T> {
  Collection(Iterable elements, [this.total])
      : elements = List.unmodifiable(elements);

  final List<T> elements;

  /// Total count of the elements on the server. May be null.
  final int total;
}
