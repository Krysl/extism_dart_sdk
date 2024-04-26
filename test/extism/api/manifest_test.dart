import 'dart:io';

import 'package:extism_dart_sdk/extism_dart_sdk.dart';
import 'package:http/http.dart' as http;
import 'package:json_schema/json_schema.dart';

import 'package:test/test.dart';

// ignore: library_prefixes
import '../utils/matchers.dart';

void main() {
  late final JsonSchema schema;
  setUpAll(() async {
    final file = 'test/extism/api/schema.json';
    final schemaFile = File(file);
    if (!schemaFile.existsSync()) {
      await http
          .get(Uri.parse(
              'https://raw.githubusercontent.com/extism/extism/main/manifest/schema.json'))
          .then((value) => File(file).writeAsBytes(value.bodyBytes));
    }
    schema = await JsonSchema.createFromUrl(file);
  });
  group('manifest test', () {
    test('from path', () {
      final manifest = Manifest.path('test/wasm/code-functions.wasm');
      expect(manifest.toJsonString(indent: '  '), SchemaMatcher(schema));
    });
    test('from path with XXX', () {
      final manifest = Manifest.path('test/wasm/code-functions.wasm')
        ..withTimeout(Duration(seconds: 1))
        ..memoryMax = 16
        ..disallowAllHosts();
      expect(manifest.toJsonString(indent: '  '), SchemaMatcher(schema));
    });
  });
}
