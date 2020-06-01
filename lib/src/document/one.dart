
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';

class One extends Relationship {
  One(Identifier identifier,
      {Map<String, Link> links = const {}, Map<String, Object> meta = const {}})
      : identifier = Just(identifier),
        super(links: links, meta: meta);

  One.empty(
      {Map<String, Link> links = const {}, Map<String, Object> meta = const {}})
      : identifier = Nothing<Identifier>(),
        super(links: links, meta: meta);


  @override
  Map<String, Object> toJson() =>
      {...super.toJson(), 'data': identifier.or(null)};

  Maybe<Identifier> identifier;

  @override
  Iterator<Identifier> get iterator =>
      identifier.map((_) => [_]).or(const []).iterator;
}
