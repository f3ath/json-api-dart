import 'package:json_api/src/server/router.dart';

abstract class RequestTarget {
  Uri url(URLDesign design);

  const RequestTarget();
}

class CollectionTarget extends RequestTarget {
  final String type;

  const CollectionTarget(this.type);

  @override
  Uri url(URLDesign design) => design.collection(this);
}

class ResourceTarget extends RequestTarget {
  final String type;
  final String id;

  const ResourceTarget(this.type, this.id);

  @override
  Uri url(URLDesign design) => design.resource(this);
}

class RelationshipTarget extends RequestTarget {
  final String type;
  final String id;
  final String relationship;

  const RelationshipTarget(this.type, this.id, this.relationship);

  @override
  Uri url(URLDesign design) => design.relationship(this);

  RelatedTarget toRelated() => RelatedTarget(type, id, relationship);
}

class RelatedTarget extends RequestTarget {
  final String type;
  final String id;
  final String relationship;

  const RelatedTarget(this.type, this.id, this.relationship);

  @override
  Uri url(URLDesign design) => design.related(this);

  RelationshipTarget toRelationship() =>
      RelationshipTarget(type, id, relationship);
}
