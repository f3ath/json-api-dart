/// A violation of the JSON:API standard
abstract class Violation {
  String get pointer;

  String get value;
}

abstract class Validatable {
  List<Violation> validate(Naming naming);
}

/// JSON:API naming rules
/// https://jsonapi.org/format/#document-member-names
abstract class Naming {
  const Naming();

  List<NamingViolation> violations(String path, Iterable<String> values);
}

class Prefixed implements Naming {
  final Naming inner;
  final String prefix;

  Prefixed(this.inner, this.prefix);

  @override
  List<NamingViolation> violations(String path, Iterable<String> values) =>
      inner.violations(prefix + path, values);
}

/// JSON:API standard naming rules
/// https://jsonapi.org/format/#document-member-names
class StandardNaming extends Naming {
  static final _disallowFirst = new RegExp(r'^[^_ -]');
  static final _disallowLast = new RegExp(r'[^_ -]$');
  static final _allowGlobally = new RegExp(r'^[a-zA-Z0-9_ \u0080-\uffff-]+$');

  const StandardNaming();

  /// Is [name] allowed by the rules
  bool allows(String name) =>
      _disallowFirst.hasMatch(name) &&
      _disallowLast.hasMatch(name) &&
      _allowGlobally.hasMatch(name);

  bool disallows(String name) => !allows(name);

  List<NamingViolation> violations(String path, Iterable<String> values) =>
      values.where(disallows).map((_) => NamingViolation(path, _)).toList();
}

/// A violation of JSON:API naming
/// https://jsonapi.org/format/#document-member-names
class NamingViolation implements Violation {
  final String pointer;
  final String value;

  NamingViolation(this.pointer, this.value);
}

/// A violation of JSON:API fields uniqueness
/// https://jsonapi.org/format/#document-resource-object-fields
class NamespaceViolation implements Violation {
  final String pointer;
  final String value;

  NamespaceViolation(this.pointer, this.value);
}
