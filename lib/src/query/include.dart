import 'dart:collection';

class Include with IterableMixin {
  final Iterable<String> _resources;

  Include(this._resources);

  factory Include.decode(Map<String, List<String>> query) {
    final resources = (query['include'] ?? []).expand((_) => _.split(','));
    return Include(resources);
  }

  @override
  // TODO: implement iterator
  Iterator get iterator => _resources.iterator;
}
