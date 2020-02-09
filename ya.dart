import 'package:http/http.dart';

void main() async {
  final c = Client();
  final r = await c.get('https://ya.ru');
  r.headers.forEach((k, v) => print('$k : $v\n'));
}