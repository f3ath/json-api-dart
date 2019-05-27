import 'package:json_api/src/server/page.dart';
import 'package:json_api/src/server/page_parameters.dart';

class NumberedPage implements Page {
  final int size;
  final int number;

  NumberedPage(this.number, this.size) {
    if (size < 1) throw ArgumentError();
    if (number < 1) throw ArgumentError();
  }

  @override
  Uri addTo(Uri uri) =>
      PageParameters({'number': number.toString()}).addTo(uri);

  @override
  NumberedPage first() => NumberedPage(1, size);

  @override
  NumberedPage last(int total) => NumberedPage((total - 1) ~/ size + 1, size);

  @override
  NumberedPage prev() => number > 1 ? NumberedPage(number - 1, size) : null;

  @override
  NumberedPage next(int total) {
    final lastPage = last(total);
    final nextPage = NumberedPage(number + 1, size);
    if (nextPage.number > lastPage.number) return null;
    return nextPage;
  }

  @override
  int get limit => size;

  @override
  int get offset => (number - 1) * size;
}
