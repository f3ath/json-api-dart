import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:test/test.dart';

void expectSameJson(Object a, Object b) =>
    expect(jsonEncode(a), jsonEncode(b));
