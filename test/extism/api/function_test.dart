import 'dart:ffi' as ffi;

import 'package:extism_dart_sdk/extism_dart_sdk.dart';
import 'package:ffi/ffi.dart';
import 'package:test/test.dart';

import '../../wasms.dart';

void main() {
  late final ExtismApi extism;

  setUpAll(() {
    extism = ExtismApi.api;
    expect(extism.version, matches(r'\d+.\d+.\d+'));
  });
  group('Plugin API tests', () {
    test('test Function', () {
      // extism.logCustom("extism=trace,cranelift=trace");
      extism.logCustom('debug');
      final wasmFilePath = WasmFiles.wasm;

      final fn = HostFunctionFactory.newFunc(
        'hello_world',
        [ExtismValType.PTR],
        [ExtismValType.PTR],
        (currentPlugin, userdata) {
          print('Hello from Dart Callback!');
          print('get userData: ${userdata.cast<Utf8>().toDartString()}');
          final cp = currentPlugin.ref;
          final strPtr = cp.inputUtf8String(0);
          print('currentPlugin get input: $strPtr');
          cp.outputString(strPtr, 0);
        },
        'Dart userData => plugin:Hello, again!'.toNativeUtf8().cast(),
        (_) {
          print('Free user data');
        },
      );

      final plugin = Plugin.fromWasmFilePath(
        wasmFilePath,
        functions: [fn.func], // TODO: 最好不调用 func
        withWasi: true,
      );

      final testData = 'test data';
      final ret = plugin.call(
        'count_vowels',
        testData.n.dataPtr,
        testData.length,
      )..inspectErr((e) {
          throw e;
        });
      print('count_vowels ret = ${ret.unwrap().toDartString()}');

      plugin.free(); //todo auto free
      fn.free(); //todo auto free
    });
  });
  group('UserData test', () {
    test('Finalizable test', () {
      final nativeFn = calloc.nativeFree;

      final timeStart = Stopwatch()..start();
      final num = 1000;
      for (var i = 0; i < num; i++) {
        void test1() {
          'test'
              .toNativeUtf8()
              .cast<ffi.Uint8>()
              .asTypedList(4, finalizer: nativeFn);
          final str = 'test123' * 100;
          UserData<ffi.Uint8>.allocate(str.length);
        }

        test1();
        if (i % 10 == 0) {
          logger.d('$i times test taking ${timeStart.elapsedMilliseconds} ms');
        }
      }
      logger.d('$num times test taking ${timeStart.elapsed.inMilliseconds} ms');
      logger.d('-' * 80);
    });
  });
  tearDownAll(() {
    extism.logDrain(
      (String output, int len) => print('[log] len = $len, output = $output'),
    );
  });
}
