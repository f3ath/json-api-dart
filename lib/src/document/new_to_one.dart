import 'package:json_api/src/document/new_identifier.dart';
import 'package:json_api/src/document/new_relationship.dart';

class NewToOne extends NewRelationship {
  NewToOne(this.identifier);

  NewToOne.empty() : this(null);

  @override
  Map<String, dynamic> toJson() => {'data': identifier, ...super.toJson()};

  final NewIdentifier? identifier;

  @override
  Iterator<NewIdentifier> get iterator =>
      identifier == null ? super.iterator : [identifier!].iterator;
}
