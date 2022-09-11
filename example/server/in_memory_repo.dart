import 'package:json_api/document.dart';
import 'package:json_api/src/nullable.dart';

import 'repository.dart';

class InMemoryRepo implements Repository {
  InMemoryRepo(Iterable<String> types) {
    for (var type in types) {
      _storage[type] = {};
    }
  }

  final _storage = <String, Map<String, Model>>{};

  @override
  Stream<Model> fetchCollection(String type) {
    return Stream.fromIterable(_collection(type).values);
  }

  @override
  Future<Model> fetch(String type, String id) async {
    return _model(type, id);
  }

  @override
  Future<void> persist(String type, Model model) async {
    _collection(type)[model.id] = model;
  }

  @override
  Stream<Identifier> addMany(
      String type, String id, String rel, Iterable<Identifier> ids) {
    final many = _many(type, id, rel);
    many.addAll(ids.map(Reference.of));
    return Stream.fromIterable(many).map((e) => e.toIdentifier());
  }

  @override
  Future<void> delete(String type, String id) async {
    _collection(type).remove(id);
  }

  @override
  Future<void> update(String type, String id, ModelProps props) async {
    _model(type, id).setFrom(props);
  }

  @override
  Future<void> replaceOne(
      String type, String id, String rel, Identifier? one) async {
    _model(type, id).one[rel] = nullable(Reference.of)(one);
  }

  @override
  Stream<Identifier> deleteMany(
          String type, String id, String rel, Iterable<Identifier> many) =>
      Stream.fromIterable(
              _many(type, id, rel)..removeAll(many.map(Reference.of)))
          .map((it) => it.toIdentifier());

  @override
  Stream<Identifier> replaceMany(
      String type, String id, String rel, Iterable<Identifier> many) {
    final set = _many(type, id, rel);
    set.clear();
    set.addAll(many.map(Reference.of));
    return Stream.fromIterable(set).map((it) => it.toIdentifier());
  }

  Map<String, Model> _collection(String type) =>
      (_storage[type] ?? (throw CollectionNotFound()));

  Model _model(String type, String id) =>
      _collection(type)[id] ?? (throw ResourceNotFound());

  Set<Reference> _many(String type, String id, String rel) =>
      _model(type, id).many[rel] ?? (throw RelationshipNotFound());
}
