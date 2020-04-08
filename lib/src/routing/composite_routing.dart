import 'package:json_api/src/routing/contract.dart';

/// URI design composed of independent URI patterns.
class CompositeRouting implements Routing {
  CompositeRouting(
      this._collection, this._resource, this._related, this._relationship);

  final CollectionUriPattern _collection;
  final ResourceUriPattern _resource;
  final RelatedUriPattern _related;
  final RelationshipUriPattern _relationship;

  @override
  Uri collection(String type) => _collection.uri(type);

  @override
  Uri related(String type, String id, String relationship) =>
      _related.uri(type, id, relationship);

  @override
  Uri relationship(String type, String id, String relationship) =>
      _relationship.uri(type, id, relationship);

  @override
  Uri resource(String type, String id) => _resource.uri(type, id);

  @override
  bool match(Uri uri, UriMatchHandler handler) =>
      _collection.match(uri, handler.collection) ||
      _resource.match(uri, handler.resource) ||
      _related.match(uri, handler.related) ||
      _relationship.match(uri, handler.relationship);
}
