import 'package:json_api/document.dart';

class Relationship {}

class ToOne implements Relationship {
  ToOne(Identifier identifier) {
    set(identifier);
  }

  ToOne.empty();

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

  static ToOne fromNullable(Identifier identifier) =>
      identifier == null ? ToOne.empty() : ToOne(identifier);
}

class ToMany implements Relationship {
  ToMany(Iterable<Identifier> identifiers) {
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
}
