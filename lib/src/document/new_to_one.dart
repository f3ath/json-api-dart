import 'package:json_api/src/document/new_identifier.dart';
import 'package:json_api/src/document/new_relationship.dart';

class NewToOne(final NewIdentifier? identifier) extends NewRelationship {
  NewToOne.empty() : this(null);

  @override
  Map<String, dynamic> toJson() => {'data': identifier, ...super.toJson()};

  @override
  Iterator<NewIdentifier> get iterator =>
      identifier == null ? super.iterator : [identifier!].iterator;
}
