class Company {
  final String id;
  final String headquarters;
  final List<String> models;
  String name;

  Company(this.id, this.name, {this.headquarters, this.models = const []});
}

class City {
  final String id;
  String name;

  City(this.id, this.name);
}

class Model {
  final String id;
  String name;

  Model(this.id, this.name);
}
