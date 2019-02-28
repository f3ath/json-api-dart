import 'package:json_api/src/document/document.dart';

class MetaDocument extends Document {
  MetaDocument(Map<String, Object> meta) : super(meta: meta) {
    ArgumentError.checkNotNull(meta);
  }

  static MetaDocument fromJson(Object json) {
    if (json is Map) {
      return MetaDocument(json['meta']);
    }
    throw 'Can not parse MetaDocument from $json';
  }

  toJson() => {'meta': meta};
}
