/// A read-only representation of a [Map]
class MapView<K, V> {
  MapView(Map<K, V> map) : _map = {...map};

  static final empty = MapView({});

  /// Same as [Map.containsValue()]
  bool containsValue(Object value) => _map.containsValue(value);

  /// Same as [Map.containsKey()]
  bool containsKey(Object key) => _map.containsKey(key);

  /// Returns the value for the given [key] or null if [key] is not in the map view.
  V operator [](Object key) => _map[key];

  /// Same as [Map.entries]
  Iterable<MapEntry<K, V>> get entries => _map.entries;

  /// Same as [Map.forEach()]
  void forEach(void f(K key, V value)) => _map.forEach(f);

  /// Same as [Map.keys]
  Iterable<K> get keys => _map.keys;

  /// Same as [Map.values]
  Iterable<V> get values => _map.values;

  /// Same as [Map.length]
  int get length => _map.length;

  /// Same as [Map.isEmpty]
  bool get isEmpty => _map.isEmpty;

  /// Same as [Map.isNotEmpty]
  bool get isNotEmpty => _map.isNotEmpty;

  /// Returns a map with the same keys and values.
  Map<K, V> toMap() => {..._map};

  Map<K, V> toJson() => toMap();
  final Map<K, V> _map;
}
