import 'dart:convert';

import 'package:test/test.dart';

void expectSameJson(Object actual, Object expected) =>
    expect(jsonDecode(jsonEncode(actual)), jsonDecode(jsonEncode(expected)));
