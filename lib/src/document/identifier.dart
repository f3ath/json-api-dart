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

  static Identifier fromJson(Object json) {
    if (json is Map) {
      return Identifier(json['type'], json['id'], meta: json['meta']);
    }
    throw 'Can not parse Indetifier from $json';
  }

  @override
  String toString() => 'Identifier($type:$id)';
}
