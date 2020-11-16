import 'package:json_api/document.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/resource.dart';

/// An empty outbound document.
class OutboundDocument {
  /// The document "meta" object.
  final meta = <String, Object>{};

  Map<String, Object> toJson() => {'meta': meta};
}

/// An outbound error document.
class OutboundErrorDocument extends OutboundDocument {
  OutboundErrorDocument(Iterable<ErrorObject> errors) {
    this.errors.addAll(errors);
  }

  /// The list of errors.
  final errors = <ErrorObject>[];

  @override
  Map<String, Object> toJson() => {
        'errors': errors,
        if (meta.isNotEmpty) 'meta': meta,
      };
}

/// An outbound data document.
class OutboundDataDocument extends OutboundDocument {
  /// Creates an instance of a document containing a single resource as the primary data.
  OutboundDataDocument.resource(Resource resource) : _data = resource;

  /// Creates an instance of a document containing a single to-be-created resource as the primary data. Used only in client-to-server requests.
  OutboundDataDocument.newResource(NewResource resource) : _data = resource;

  /// Creates an instance of a document containing a collection of resources as the primary data.
  OutboundDataDocument.collection(Iterable<Resource> collection)
      : _data = collection.toList();

  /// Creates an instance of a document containing a to-one relationship.
  OutboundDataDocument.one(One one) : _data = one.identifier {
    meta.addAll(one.meta);
    links.addAll(one.links);
  }

  /// Creates an instance of a document containing a to-many relationship.
  OutboundDataDocument.many(Many many) : _data = many.toList() {
    meta.addAll(many.meta);
    links.addAll(many.links);
  }

  final Object _data;

  /// Links related to the primary data.
  final links = <String, Link>{};

  /// A list of included resources.
  final included = <Resource>[];

  @override
  Map<String, Object> toJson() => {
        'data': _data,
        if (links.isNotEmpty) 'links': links,
        if (included.isNotEmpty) 'included': included,
        if (meta.isNotEmpty) 'meta': meta,
      };
}
