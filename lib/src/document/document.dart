import 'package:json_api/document.dart';
import 'package:json_api/src/document/api.dart';
import 'package:json_api/src/document/document_exception.dart';
import 'package:json_api/src/document/error_object.dart';
import 'package:json_api/src/document/json_encodable.dart';
import 'package:json_api/src/document/primary_data.dart';
import 'package:json_api/src/nullable.dart';

class Document<D extends PrimaryData> implements JsonEncodable {
  /// Create a document with primary data
  Document(this.data,
      {Map<String, Object> meta, Api api, Iterable<ResourceObject> included})
      : errors = const [],
        included = List.unmodifiable(included ?? []),
        meta = Map.unmodifiable(meta ?? const {}),
        api = api ?? Api(),
        isError = false,
        isCompound = included != null,
        isMeta = false {
    ArgumentError.checkNotNull(data);
  }

  /// Create a document with errors (no primary data)
  Document.error(Iterable<ErrorObject> errors,
      {Map<String, Object> meta, Api api})
      : data = null,
        included = const [],
        meta = Map.unmodifiable(meta ?? const {}),
        errors = List.unmodifiable(errors ?? const []),
        api = api ?? Api(),
        isCompound = false,
        isError = true,
        isMeta = false;

  /// Create an empty document (no primary data and no errors)
  Document.empty(Map<String, Object> meta, {Api api})
      : data = null,
        meta = Map.unmodifiable(meta ?? const {}),
        included = const [],
        errors = const [],
        api = api ?? Api(),
        isError = false,
        isCompound = false,
        isMeta = true {
    ArgumentError.checkNotNull(meta);
  }

  /// The Primary Data. May be null.
  final D data;

  /// Included objects in a compound document
  final List<ResourceObject> included;

  final bool isCompound;

  /// List of errors. May be empty or null.
  final List<ErrorObject> errors;

  /// Meta data. May be empty.
  final Map<String, Object> meta;

  /// The `jsonapi` object.
  final Api api;

  /// True for error documents.
  final bool isError;

  /// True for non-error meta-only documents.
  final bool isMeta;

  /// Reconstructs a document with the specified primary data
  static Document<Data> fromJson<Data extends PrimaryData>(
      Object json, Data Function(Object json) primaryData) {
    if (json is Map) {
      final api = nullable(Api.fromJson)(json['jsonapi']);
      final meta = json['meta'];
      if (json.containsKey('errors')) {
        final errors = json['errors'];
        if (errors is List) {
          return Document.error(errors.map(ErrorObject.fromJson),
              meta: meta, api: api);
        }
      } else if (json.containsKey('data')) {
        final included = json['included'];
        final doc = Document(primaryData(json), meta: meta, api: api);
        if (included is List) {
          return CompoundDocument(doc, included.map(ResourceObject.fromJson));
        }
        return doc;
      } else if (json['meta'] != null) {
        return Document.empty(meta, api: api);
      }
      throw DocumentException('Unrecognized JSON:API document structure');
    }
    throw DocumentException('A JSON:API document must be a JSON object');
  }

  static const contentType = 'application/vnd.api+json';

  @override
  Map<String, Object> toJson() => {
        if (data != null) ...data.toJson() else if (isError) 'errors': errors,
        if (isMeta || meta.isNotEmpty) 'meta': meta,
        if (api.isNotEmpty) 'jsonapi': api,
        if (isCompound) 'included': included,
      };
}

class CompoundDocument<D extends PrimaryData> implements Document<D> {
  CompoundDocument(this._document, Iterable<ResourceObject> included)
      : included = List.unmodifiable(included);

  final Document<D> _document;
  @override
  final List<ResourceObject> included;

  @override
  Api get api => _document.api;

  @override
  D get data => _document.data;

  @override
  List<ErrorObject> get errors => _document.errors;

  @override
  bool get isCompound => true;

  @override
  bool get isError => false;

  @override
  bool get isMeta => false;

  @override
  Map<String, Object> get meta => _document.meta;

  @override
  Map<String, Object> toJson() => {..._document.toJson(), 'included': included};
}
