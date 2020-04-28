import 'package:json_api/document.dart';

class ToOne extends RelationshipObject {
  ToOne(Identifier identifier, {Map<String, Link> links})
      : super(links: links) {
    set(identifier);
  }

  ToOne.empty({Map<String, Link> links}) : super(links: links);

  final _values = <Identifier>{};

  bool get isEmpty => _values.isEmpty;

  T mapIfExists<T>(T Function(Identifier _) map, T Function() orElse) =>
      _values.isEmpty ? orElse() : map(_values.first);

  List<Identifier> toList() => mapIfExists((_) => [_], () => []);

  void set(Identifier identifier) {
    ArgumentError.checkNotNull(identifier, 'identifier');
    _values
      ..clear()
      ..add(identifier);
  }

  void clear() {
    _values.clear();
  }

  @override
  Map<String, Object> toJson() => {...super.toJson(), 'data': _values.first};

  static ToOne fromNullable(Identifier identifier) =>
      identifier == null ? ToOne.empty() : ToOne(identifier);
}

class ToMany extends RelationshipObject {
  ToMany(Iterable<Identifier> identifiers, {Map<String, Link> links})
      : super(links: links) {
    set(identifiers);
  }

  final _map = <String, Identifier>{};

  int get length => _map.length;

  List<Identifier> toList() => [..._map.values];

  void set(Iterable<Identifier> identifiers) {
    _map..clear();
    identifiers.forEach((i) => _map[i.key] = i);
  }

  void remove(Iterable<Identifier> identifiers) {
    identifiers.forEach((i) => _map.remove(i.key));
  }

  void addAll(Iterable<Identifier> identifiers) {
    identifiers.forEach((i) => _map[i.key] = i);
  }

  @override
  Map<String, Object> toJson() => {...super.toJson(), 'data': _map.values};
}
