import 'package:json_api/routing.dart';

class CollectionTarget {
  CollectionTarget(this.type);

  final String type;

  Uri link(UriFactory factory) => factory.collection(type);
}

class ResourceTarget implements CollectionTarget {
  ResourceTarget(this.type, this.id);

  @override
  final String type;

  final String id;

  @override
  Uri link(UriFactory factory) => factory.resource(type, id);
}

class RelationshipTarget implements ResourceTarget {
  RelationshipTarget(this.type, this.id, this.relationship);

  @override
  final String type;

  @override
  final String id;

  final String relationship;

  @override
  Uri link(UriFactory factory) => factory.relationship(type, id, relationship);
}

class RelatedTarget implements ResourceTarget {
  RelatedTarget(this.type, this.id, this.relationship);

  @override
  final String type;

  @override
  final String id;

  final String relationship;

  @override
  Uri link(UriFactory factory) => factory.related(type, id, relationship);
}
