import 'package:json_api/src/server/page.dart';

abstract class PaginationStrategy {
  Page getPage(Map<String, List<String>> query);
}
