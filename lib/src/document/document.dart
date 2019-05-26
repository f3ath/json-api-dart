import 'package:json_api/src/document/error.dart';
import 'package:json_api/src/document/json_api.dart';
import 'package:json_api/src/document/primary_data.dart';

class Document<Data extends PrimaryData> {
  /// The Primary Data
  final Data data;
  final JsonApi api;

  final List<JsonApiError> errors;
  final Map<String, Object> meta;

  /// Create a document with primary data
  Document(this.data, {Map<String, Object> meta, this.api})
      : this.errors = null,
        this.meta = (meta == null ? null : Map.from(meta));

  /// Create a document with errors (no primary data)
  Document.error(Iterable<JsonApiError> errors,
      {Map<String, Object> meta, this.api})
      : this.data = null,
        this.errors = List.from(errors),
        this.meta = (meta == null ? null : Map.from(meta));

  /// Create an empty document (no primary data and no errors)
  Document.empty(Map<String, Object> meta, {this.api})
      : this.data = null,
        this.errors = null,
        this.meta = (meta == null ? null : Map.from(meta)) {
    ArgumentError.checkNotNull(meta, 'meta');
  }

  Map<String, Object> toJson() => {
        if (data != null)
          ...data.toJson()
        else
          if (errors != null) ...{'errors': errors.map(_errorToJson).toList()},
        if (meta != null) ...{'meta': meta},
        if (api != null) ...{'jsonapi': api},
      };

  Map<String, Object> _errorToJson(JsonApiError error) {
    final source = {
      if (error.sourcePointer != null) ...{'pointer': error.sourcePointer},
      if (error.sourceParameter != null) ...{
        'parameter': error.sourceParameter
      },
    };
    return {
      if (error.id != null) ...{'id': error.id},
      if (error.status != null) ...{'status': error.status},
      if (error.code != null) ...{'code': error.code},
      if (error.title != null) ...{'title': error.title},
      if (error.detail != null) ...{'detail': error.detail},
      if (error.meta.isNotEmpty != null) ...{'meta': error.meta},
      if (error.about != null) ...{
        'links': {'about': error.about}
      },
      if (source.isNotEmpty) ...{'source': source},
    };
  }
}
