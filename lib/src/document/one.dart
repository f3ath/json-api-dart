import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/relationship.dart';

class One extends Relationship {
  One(Identifier /*!*/ identifier) : identifier = identifier;

  One.empty() : identifier = null;

  @override
  Map<String, dynamic> toJson() => {'data': identifier, ...super.toJson()};

  /// Nullable
  final Identifier /*?*/ identifier;

  @override
  Iterator<Identifier /*!*/ > get iterator =>
      identifier == null ? <Identifier>[].iterator : [identifier].iterator;
}
