import 'dart:io';

import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/src/url_design/path_based_url_design.dart';
import 'package:test/test.dart';

/// Make sure [JsonApiClient] can be used in a browser
void main() async {
  test('can create and fetch a resource', () async {
    final uri = Uri.parse('http://localhost:8080');
    final channel = spawnHybridUri('server.dart', message: uri);
    final HttpServer server = await channel.stream.first;
    final client = UrlAwareClient(PathBasedUrlDesign(uri));
    await client.createResource(
        Resource('messages', '1', attributes: {'text': 'Hello World'}));
    final r = await client.fetchResource('messages', '1');
    expect(r.data.unwrap().attributes['text'], 'Hello World');
    client.close();
    await server.close();
  }, testOn: 'browser');
}
