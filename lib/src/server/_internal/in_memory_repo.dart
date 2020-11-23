import 'repo.dart';

class InMemoryRepo implements Repo {
  InMemoryRepo(Iterable<String> types) {
    types.forEach((_) {
      _storage[_] = {};
    });
  }

  final _storage = <String, Map<String, Model>>{};

  @override
  Stream<Entity<Model>> fetchCollection(String type) async* {
    if (!_storage.containsKey(type)) {
      throw CollectionNotFound();
    }
    for (final e in _storage[type].entries) {
      yield Entity(e.key, e.value);
    }
  }

  @override
  Future<Model /*?*/ > fetch(String type, String id) async {
    return _storage[type][id];
  }

  @override
  Future<void> persist(String type, String id, Model model) async {
    _storage[type][id] = model;
  }

  @override
  Stream<String> addMany(
      String type, String id, String rel, Iterable<String> refs) {
    final model = _storage[type][id];
    model.addMany(rel, refs);
    return Stream.fromIterable(model.many[rel]);
  }

  @override
  Future<void> delete(String type, String id) async {
    _storage[type].remove(id);
  }

  @override
  Future<void> update(String type, String id, Model model) async {
    _storage[type][id].setFrom(model);
  }

  @override
  Future<void> replaceOne(
      String type, String id, String relationship, String key) async {
    _storage[type][id].one[relationship] = key;
  }

  @override
  Future<void> deleteOne(String type, String id, String relationship) async {
    _storage[type][id].one[relationship] = null;
  }

  @override
  Stream<String> deleteMany(
      String type, String id, String relationship, Iterable<String> refs) {
    _storage[type][id].many[relationship].removeAll(refs);
    return Stream.fromIterable(_storage[type][id].many[relationship]);
  }

  @override
  Stream<String> replaceMany(
      String type, String id, String relationship, Iterable<String> refs) {
    _storage[type][id].many[relationship]
      ..clear()
      ..addAll(refs);
    return Stream.fromIterable(_storage[type][id].many[relationship]);
  }
}
