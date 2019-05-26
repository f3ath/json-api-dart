class Collection<T> {
  final Iterable<T> elements;
  final int total;

  Collection(this.elements, {this.total});

  Collection<K> map<K>(K fn(T _)) => Collection(elements.map(fn), total: total);
}
