import 'package:json_api/handler.dart';

class MockHandler<Rq, Rs> implements Handler<Rq, Rs> {
  Rq /*?*/ request;
  Rs /*?*/ response;

  @override
  Future<Rs> call(Rq request) async {
    this.request = request;
    return response;
  }
}
