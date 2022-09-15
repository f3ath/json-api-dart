import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/relationship.dart';

class ToOne extends Relationship<Identifier> {
  ToOne(this.identifier);

  ToOne.empty() : this(null);

  @override
  Map<String, dynamic> toJson() => {'data': identifier, ...super.toJson()};

  final Identifier? identifier;

  @override
  Iterator<Identifier> get iterator =>
      identifier == null ? super.iterator : [identifier!].iterator;
}
