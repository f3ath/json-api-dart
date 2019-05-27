/// JSON API Document naming rules
///
/// Details: https://jsonapi.org/format/#document-member-names
abstract class Naming {
  const Naming();

  /// Is [name] allowed by the rules
  bool allows(String name);

  /// Is [name] disallowed by the rules
  bool disallows(String name) => !allows(name);
}
