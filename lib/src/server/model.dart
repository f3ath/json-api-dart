import 'package:json_api/document.dart';

class Model {
  Model(this.type);

  final String type;
  final attributes = <String, Object /*?*/ >{};
  final one = <String, Identifier /*?*/ >{};
  final many = <String, List<Identifier>>{};
  final meta = <String, Object /*?*/ >{};
}
