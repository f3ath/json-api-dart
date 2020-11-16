import 'package:json_api/document.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/resource.dart';

/// An empty outbound document.
class OutboundDocument {
  /// Creates an instance of a document containing a single resource as the primary data.
  static OutboundDataDocument<Resource> resource(Resource resource) =>
      OutboundDataDocument._(resource);

  /// Creates an instance of a document containing a collection of resources as the primary data.
  static OutboundDataDocument<List<Resource>> collection(
          Iterable<Resource> collection) =>
      OutboundDataDocument._(collection.toList());

  /// Creates an instance of a document containing a to-one relationship.
  static OutboundDataDocument<Identifier /*?*/ > one(One one) =>
      OutboundDataDocument._(one.identifier)
        ..meta.addAll(one.meta)
        ..links.addAll(one.links);

  /// Creates an instance of a document containing a to-many relationship.
  static OutboundDataDocument<List<Identifier>> many(Many many) =>
      OutboundDataDocument._(many.toList())
        ..meta.addAll(many.meta)
        ..links.addAll(many.links);

  static OutboundErrorDocument error(Iterable<ErrorObject> errors) =>
      OutboundErrorDocument._()..errors.addAll(errors);

  /// The document "meta" object.
  final meta = <String, Object>{};

  Map<String, Object> toJson() => {'meta': meta};
}

/// An outbound error document.
class OutboundErrorDocument extends OutboundDocument {
  OutboundErrorDocument._();

  /// The list of errors.
  final errors = <ErrorObject>[];

  @override
  Map<String, Object> toJson() => {
        'errors': errors,
        if (meta.isNotEmpty) 'meta': meta,
      };
}

/// An outbound data document.
class OutboundDataDocument<D> extends OutboundDocument {
  OutboundDataDocument._(this.data);

  final D data;

  /// Links related to the primary data.
  final links = <String, Link>{};

  /// A list of included resources.
  final included = <Resource>[];

  @override
  Map<String, Object> toJson() => {
        'data': data,
        if (links.isNotEmpty) 'links': links,
        if (included.isNotEmpty) 'included': included,
        if (meta.isNotEmpty) 'meta': meta,
      };
}
