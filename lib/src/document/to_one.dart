import 'package:json_api/src/document/new_identifier.dart';
import 'package:json_api/src/document/relationship.dart';

class ToOne(final Identifier? identifier) extends Relationship {
  ToOne.empty() : this(null);

  @override
  Map<String, Object?> toJson() => {'data': identifier, ...super.toJson()};

  @override
  Iterator<Identifier> get iterator =>
      identifier == null ? super.iterator : [identifier!].iterator;
}
