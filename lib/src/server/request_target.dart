import 'package:json_api/src/server/contracts/router.dart';

abstract class RequestTarget {
  Uri uri(UriBuilder builder);
}

class CollectionTarget implements RequestTarget {
  final String type;

  const CollectionTarget(this.type);

  @override
  Uri uri(UriBuilder builder) => builder.collection(type);
}

class ResourceTarget implements RequestTarget {
  final String type;
  final String id;

  const ResourceTarget(this.type, this.id);

  @override
  Uri uri(UriBuilder builder) => builder.resource(type, id);
}

class RelationshipTarget implements RequestTarget {
  final String type;
  final String id;
  final String relationship;

  const RelationshipTarget(this.type, this.id, this.relationship);

  @override
  Uri uri(UriBuilder builder) => builder.relationship(type, id, relationship);
}

class RelatedResourceTarget implements RequestTarget {
  final String type;
  final String id;
  final String relationship;

  const RelatedResourceTarget(this.type, this.id, this.relationship);

  @override
  Uri uri(UriBuilder builder) =>
      builder.relatedResource(type, id, relationship);
}
