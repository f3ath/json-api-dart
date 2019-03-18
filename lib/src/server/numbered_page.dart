import 'dart:math';

import 'package:json_api/src/server/contracts/page.dart';

class NumberedPage extends Page {
  final int number;
  final int total;

  NumberedPage(this.number, {this.total});

  NumberedPage.fromQueryParameters(Map<String, String> queryParameters,
      {int total})
      : this(int.parse(queryParameters['page[number]'] ?? '1'), total: total);

  int get offset => number - 1;

  Map<String, String> get parameters {
    if (number > 1) {
      return {'page[number]': number.toString()};
    }
    return {};
  }

  Page get first => NumberedPage(1, total: total);

  Page get last => NumberedPage(total, total: total);

  Page get next => NumberedPage(min(number + 1, total), total: total);

  Page get prev => NumberedPage(max(number - 1, 1), total: total);
}
