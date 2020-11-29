import 'package:json_api/core.dart';

import 'repo.dart';

class InMemoryRepo implements Repo {
  InMemoryRepo(Iterable<String> types) {
    types.forEach((_) {
      _storage[_] = {};
    });
  }

  final _storage = <String, Map<String, Model>>{};

  @override
  Stream<Model> fetchCollection(String type) {
    return Stream.fromIterable(_collection(type).values);
  }

  @override
  Future<Model> fetch(Ref ref) async {
    return _model(ref);
  }

  @override
  Future<void> persist(Model model) async {
    _collection(model.ref.type)[model.ref.id] = model;
  }

  @override
  Stream<Ref> addMany(Ref ref, String rel, Iterable<Ref> refs) {
    final model = _model(ref);
    final many = model.many[rel];
    if (many == null) throw RelationshipNotFound(rel);
    many.addAll(refs);
    return Stream.fromIterable(many);
  }

  @override
  Future<void> delete(Ref ref) async {
    _collection(ref.type).remove(ref.id);
  }

  @override
  Future<void> update(Ref ref, ModelProps props) async {
    _model(ref).setFrom(props);
  }

  @override
  Future<void> replaceOne(Ref ref, String rel, Ref? one) async {
    _model(ref).one[rel] = one;
  }

  @override
  Stream<Ref> deleteMany(Ref ref, String rel, Iterable<Ref> refs) {
    return Stream.fromIterable(_many(ref, rel)..removeAll(refs));
  }

  @override
  Stream<Ref> replaceMany(Ref ref, String rel, Iterable<Ref> refs) {
    return Stream.fromIterable(_many(ref, rel)
      ..clear()
      ..addAll(refs));
  }

  Map<String, Model> _collection(String type) =>
      (_storage[type] ?? (throw CollectionNotFound()));

  Model _model(Ref ref) =>
      _collection(ref.type)[ref.id] ?? (throw ResourceNotFound());

  Set<Ref> _many(Ref ref, String rel) =>
      _model(ref).many[rel] ?? (throw RelationshipNotFound(rel));
}
