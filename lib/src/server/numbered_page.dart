import 'dart:math';

import 'package:json_api/src/server/page.dart';

/// This class represents a numbered page. It only concerns the page number and
/// possibly the total number of pages. The page size (how many records per page)
/// is irrelevant.
class NumberedPage extends Page {
  static const parameterName = 'page[number]';

  /// The page number
  final int number;

  /// The total number of pages
  final int total;

  NumberedPage(this.number, {this.total});

  NumberedPage.fromQueryParameters(Map<String, String> queryParameters,
      {int total})
      : this(int.parse(queryParameters[parameterName] ?? '1'), total: total);

  int get offset => number - 1;

  Map<String, String> get queryParameters => {parameterName: number.toString()};

  Page get first => NumberedPage(1, total: total);

  Page get last => NumberedPage(total, total: total);

  Page get next => NumberedPage(min(number + 1, total), total: total);

  Page get prev => NumberedPage(max(number - 1, 1), total: total);
}
