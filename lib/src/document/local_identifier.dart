import 'package:json_api/document.dart';

class LocalIdentifier implements NewIdentifier {
  LocalIdentifier(this.type, this.lid);

  /// Resource type.
  @override
  final String type;

  /// Resource id.
  @override
  final id = null;

  /// Local Resource id.
  @override
  final String lid;

  /// Identifier meta-data.
  @override
  final meta = <String, Object?>{};

  @override
  Map<String, Object> toJson() => {
        'type': type,
        'lid': lid,
        if (meta.isNotEmpty) 'meta': meta,
      };

  Identifier toIdentifier(String id) => Identifier(type, id)..meta.addAll(meta);
}
