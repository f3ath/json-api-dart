import 'package:json_api/document.dart';
import 'repository.dart';
import 'package:json_api/src/nullable.dart';

class InMemoryRepo implements Repository {
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
  Future<Model> fetch(String type, String id) async {
    return _model(type, id);
  }

  @override
  Future<void> persist(String type, Model model) async {
    _collection(type)[model.id] = model;
  }

  @override
  Stream<Identity> addMany(
      String type, String id, String rel, Iterable<Identity> ids) {
    final many = _many(type, id, rel);
    many.addAll(ids.map(Ref.of));
    return Stream.fromIterable(many);
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
      String type, String id, String rel, Identity? one) async {
    _model(type, id).one[rel] = nullable(Ref.of)(one);
  }

  @override
  Stream<Identity> deleteMany(
          String type, String id, String rel, Iterable<Identity> many) =>
      Stream.fromIterable(_many(type, id, rel)..removeAll(many.map(Ref.of)));

  @override
  Stream<Identity> replaceMany(
          String type, String id, String rel, Iterable<Identity> many) =>
      Stream.fromIterable(_many(type, id, rel)
        ..clear()
        ..addAll(many.map(Ref.of)));

  Map<String, Model> _collection(String type) =>
      (_storage[type] ?? (throw CollectionNotFound()));

  Model _model(String type, String id) =>
      _collection(type)[id] ?? (throw ResourceNotFound());

  Set<Ref> _many(String type, String id, String rel) =>
      _model(type, id).many[rel] ?? (throw RelationshipNotFound());
}
