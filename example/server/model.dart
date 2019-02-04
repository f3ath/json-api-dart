abstract class HasId {
  String get id;
}

class Brand implements HasId {
  final String name;
  final String id;
  final String headquarters;
  final List<String> models;

  Brand(this.id, this.name, {this.headquarters, this.models = const []});
}

class City implements HasId {
  final String name;
  final String id;

  City(this.id, this.name);
}

class Car implements HasId {
  final String name;
  final String id;

  Car(this.id, this.name);
}
