import 'package:json_api/src/document/new_identifier.dart';
import 'package:json_api/src/document/relationship.dart';

class ToOne extends Relationship {
  ToOne(this.identifier);

  ToOne.empty() : this(null);

  @override
  Map<String, dynamic> toJson() => {'data': identifier, ...super.toJson()};

  final Identifier? identifier;

  @override
  Iterator<Identifier> get iterator =>
      identifier == null ? super.iterator : [identifier!].iterator;
}
