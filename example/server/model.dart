abstract class HasId {
  String get id;
}

class Brand implements HasId {
  final String id;
  final String headquarters;
  final List<String> models;
  String name;

  Brand(this.id, this.name, {this.headquarters, this.models = const []});
}

class City implements HasId {
  final String id;
  String name;

  City(this.id, this.name);
}

class Car implements HasId {
  final String id;
  String name;

  Car(this.id, this.name);
}
