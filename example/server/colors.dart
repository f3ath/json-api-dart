import 'package:json_api/document.dart';
import 'package:uuid/uuid.dart';

final Map<String, Resource> colors = Map.fromIterable(
    const [
      ['black', '000000'],
      ['silver', 'c0c0c0'],
      ['gray', '808080'],
      ['white', 'ffffff'],
      ['maroon', '800000'],
      ['red', 'ff0000'],
      ['purple', '800080'],
      ['fuchsia', 'ff00ff'],
      ['green', '008000'],
      ['lime', '00ff00'],
      ['olive', '808000'],
      ['yellow', 'ffff00'],
      ['navy', '000080'],
      ['blue', '0000ff'],
      ['teal', '008080'],
      ['aqua', '00ffff'],
    ].map((c) => Resource('colors', Uuid().v4(),
        attributes: {'name': c[0], 'rgb': c[1]})),
    key: (r) => r.id);
