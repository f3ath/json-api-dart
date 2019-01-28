import 'package:json_api/src/document/validation.dart';

/// JSON:API identifier object
/// https://jsonapi.org/format/#document-resource-identifier-objects
class Identifier implements Validatable {
  final String type;
  final String id;
  final meta = <String, Object>{};

  Identifier(this.type, this.id, {Map<String, Object> meta}) {
    ArgumentError.checkNotNull(id, 'id');
    ArgumentError.checkNotNull(type, 'type');
    this.meta.addAll(meta ?? {});
  }

  validate(Naming naming) => (naming.violations('/type', [type]) +
          naming.violations('/meta', meta.keys))
      .toList();

  toJson() {
    final json = <String, Object>{'type': type, 'id': id};
    if (meta.isNotEmpty) json['meta'] = meta;
    return json;
  }

  factory Identifier.fromJson(Map json) =>
      Identifier(json['type'], json['id'], meta: json['meta']);
}
