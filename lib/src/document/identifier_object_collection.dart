import 'package:json_api/src/document/collection.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/identifier_object.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/relationship.dart';

class IdentifierObjectCollection extends Collection<IdentifierObject>
    implements ResourceLinkage {
  final Link related;

  IdentifierObjectCollection(Iterable<IdentifierObject> elements,
      {this.related})
      : super(elements);

  Map<String, Link> get links => {'related': related};

  static IdentifierObjectCollection parse(Object json) {
    if (json is Map) {
      return fromData(json['data']);
    }
  }

  static IdentifierObjectCollection fromData(Object data) {
    if (data is List) {
      return IdentifierObjectCollection(data.map(IdentifierObject.fromData));
    }
  }

  toJson() => elements.toList();

  List<Identifier> toIdentifiers() =>
      elements.map((_) => _.toIdentifier()).toList();
}
