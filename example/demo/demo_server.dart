import 'dart:io';

import 'package:json_api/http.dart';
import 'package:json_api/server.dart';
import 'package:pedantic/pedantic.dart';
import 'package:sqlite3/sqlite3.dart';

import 'dart_http_handler.dart';
import 'printing_logger.dart';
import 'sqlite_controller.dart';

class DemoServer {
  DemoServer(this._initSql, {String address, int port = 8080})
      : _address = address ?? 'localhost',
        _port = port;

  final String _address;
  final int _port;
  final String _initSql;

  Database _database;
  HttpServer _server;

  bool get isStarted => _database != null || _server != null;

  String get uri => 'http://${_address}:$_port';

  Future<void> start() async {
    if (isStarted) throw StateError('Server already started');
    try {
      _database = sqlite3.openInMemory();
      _database.execute(_initSql);
      _server = await HttpServer.bind(_address, _port);
      final controller = SqliteController(_database);
      final jsonApiServer =
          JsonApiHandler(controller, exposeInternalErrors: true);
      final _handler =
          CorsHandler(LoggingHttpHandler(jsonApiServer, PrintingLogger()));
      unawaited(_server.forEach(DartHttpHandler(_handler)));
    } on Exception {
      await stop();
      rethrow;
    }
  }

  Future<void> stop({bool force = false}) async {
    if (_database != null) {
      _database.dispose();
    }
    if (_server != null) {
      await _server.close(force: force);
    }
  }
}
