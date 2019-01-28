import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/validation.dart';

abstract class Relationship extends Validatable {
  Object get data;

  final Link self;
  final Link related;

  Relationship({this.self, this.related});

  Relationship replace({Link self, Link related});

  Map<String, Object> toJson() {
    final json = {'data': data};
    final links = {'self': self, 'related': related}
      ..removeWhere((k, v) => v == null);
    if (links.isNotEmpty) {
      json['links'] = links;
    }
    return json;
  }
}

class ToMany extends Relationship {
  final identifiers = <Identifier>[];

  ToMany(List<Identifier> identifiers, {Link self, Link related})
      : super(self: self, related: related) {
    ArgumentError.checkNotNull(identifiers, 'identifiers');
    this.identifiers.addAll(identifiers);
  }

  Object get data => identifiers.toList();

  validate(Naming naming) => identifiers
      .toList()
      .asMap()
      .entries
      .expand((_) => _.value.validate(Prefixed(naming, '/${_.key}')))
      .toList();

  ToMany replace({Link self, Link related}) => ToMany(this.identifiers,
      self: self ?? this.self, related: related ?? this.related);
}

class ToOne extends Relationship {
  final Identifier identifier;

  ToOne(this.identifier, {Link self, Link related})
      : super(self: self, related: related) {
    ArgumentError.checkNotNull(identifier, 'identifier');
  }

  Object get data => identifier;

  validate(Naming naming) => identifier.validate(naming);

  ToOne replace({Link self, Link related}) => ToOne(this.identifier,
      self: self ?? this.self, related: related ?? this.related);
}
