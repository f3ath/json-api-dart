import 'package:json_api/src/document/resource_collection.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource.dart';

class ToOne extends Relationship {
  ToOne(this.identifier);

  ToOne.empty() : this(null);

  @override
  Map<String, dynamic> toJson() => {'data': identifier, ...super.toJson()};

  final Identifier? identifier;

  @override
  Iterator<Identifier> get iterator =>
      identifier == null ? <Identifier>[].iterator : [identifier!].iterator;

  /// Finds the referenced resource in the [collection].
  Resource? findIn(ResourceCollection collection) =>
      collection[identifier?.key];
}
