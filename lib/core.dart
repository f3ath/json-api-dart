/// A reference to a resource
class Ref {
  const Ref(this.type, this.id);

  final String type;

  final String id;

  @override
  final hashCode = 0;

  @override
  bool operator ==(Object other) =>
      other is Ref && type == other.type && id == other.id;
}

class ModelProps {
  final attributes = <String, Object?>{};
  final one = <String, Ref?>{};
  final many = <String, Set<Ref>>{};

  void setFrom(ModelProps other) {
    other.attributes.forEach((key, value) {
      attributes[key] = value;
    });
    other.one.forEach((key, value) {
      one[key] = value;
    });
    other.many.forEach((key, value) {
      many[key] = {...value};
    });
  }
}

/// A model of a resource. Essentially, this is the core of a resource object.
class Model extends ModelProps {
  Model(this.ref);

  final Ref ref;
}
