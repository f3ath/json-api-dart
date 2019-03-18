import 'package:json_api/src/document/error.dart';
import 'package:json_api/src/document/primary_data.dart';

class Document<Data extends PrimaryData> {
  /// The Primary Data
  final Data data;

  final List<JsonApiError> errors;
  final Map<String, Object> meta;

  Document(this.data, {Map<String, Object> meta})
      : this.errors = null,
        this.meta = (meta == null || meta.isEmpty ? null : Map.from(meta));

  Document.error(Iterable<JsonApiError> errors, {Map<String, Object> meta})
      : this.data = null,
        this.errors = List.from(errors),
        this.meta = (meta == null || meta.isEmpty ? null : Map.from(meta));

  Document.empty(Map<String, Object> meta)
      : this.data = null,
        this.errors = null,
        this.meta = (meta == null || meta.isEmpty ? null : Map.from(meta)) {
    ArgumentError.checkNotNull(meta, 'meta');
  }

  Map<String, Object> toJson() {
    Map<String, Object> json = {};
    if (data != null) {
      json = data.toJson();
    } else if (errors != null) {
      json = {'errors': errors};
    }
    if (meta != null && meta.isNotEmpty) {
      json['meta'] = meta;
    }
    // TODO: add `jsonapi` member
    return json;
  }
}
