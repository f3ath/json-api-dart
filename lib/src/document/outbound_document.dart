import 'package:json_api/src/document/error_object.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/many.dart';
import 'package:json_api/src/document/new_resource.dart';
import 'package:json_api/src/document/one.dart';
import 'package:json_api/src/document/resource.dart';

/// A sever-to-client document.
class OutboundDocument {
  /// The document "meta" object.
  final meta = <String, Object?>{};

  /// Returns the JSON representation.
  Map<String, Object?> toJson() => {'meta': meta};
}

/// A sever-to-client document with errors.
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

/// A sever-to-client document with data.
class OutboundDataDocument extends OutboundDocument {
  /// Creates an instance of a document containing a single resource as the primary data.
  OutboundDataDocument.resource(Resource? this.data);

  /// Creates an instance of a document containing a single to-be-created resource as the primary data. Used only in client-to-server requests.
  OutboundDataDocument.newResource(NewResource this.data);

  /// Creates an instance of a document containing a collection of resources as the primary data.
  OutboundDataDocument.collection(Iterable<Resource> collection)
      : data = collection.toList();

  /// Creates an instance of a document containing a to-one relationship.
  OutboundDataDocument.one(ToOne one) : data = one.identifier {
    meta.addAll(one.meta);
    links.addAll(one.links);
  }

  /// Creates an instance of a document containing a to-many relationship.
  OutboundDataDocument.many(ToMany many) : data = many.toList() {
    meta.addAll(many.meta);
    links.addAll(many.links);
  }

  /// Document data.
  final Object? data;

  /// Links related to the primary data.
  final links = <String, Link>{};

  /// A list of included resources.
  final included = <Resource>[];

  @override
  Map<String, Object?> toJson() => {
        'data': data,
        if (links.isNotEmpty) 'links': links,
        if (included.isNotEmpty) 'included': included,
        if (meta.isNotEmpty) 'meta': meta,
      };
}
