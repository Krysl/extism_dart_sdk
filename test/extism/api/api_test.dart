import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:extism_dart_sdk/extism/generated_bindings.dart';
import 'package:extism_dart_sdk/extism_dart_sdk.dart';
import 'package:ffi/ffi.dart';
import 'package:test/test.dart';

import '../../wasms.dart';

void main() {
  late final ExtismApi extism;

  setUpAll(() {
    extism = ExtismApi.api;
  });
  group('Extism C API tests', () {
    test('extismVersion', () {
      expect(extism.version, matches(r'\d+.\d+.\d+'));
    });

    test('code from Extism C SDK Example', () {
      // extism.logCustom("extism=trace,cranelift=trace");
      extism.logCustom('debug');
      final wasm = File(WasmFiles.wasm).readAsBytesSync();

      void helloWorld(
          ffi.Pointer<ExtismCurrentPlugin> plugin,
          ffi.Pointer<ExtismVal> inputs,
          DartExtismSize nInputs,
          ffi.Pointer<ExtismVal> outputs,
          DartExtismSize nOutputs,
          ffi.Pointer<ffi.Void> data) {
        print('Hello from Dart Callback!');
        print('get userData: ${data.cast<Utf8>().toDartString()}');

        final ptrOffs = inputs[0].v.i64;

        final buf = extism.currentPluginMemory(plugin) + ptrOffs;
        final length = extism
            .currentPluginMemoryLength(plugin, ptrOffs)
            ;

        print('get currentPluginMemory: ${buf.toDartString(length: length)}');
      }

      final fn1 = extism.functionNew(
        'hello_world',
        [ExtismValType.I64],
        [ExtismValType.I64],
        helloWorld.nativeCallable,
        'Dart userData => plugin:Hello, again!'.n.voidPtr,
        (ffi.Pointer<ffi.Void> _) {
          print('freeUserData');
        },
      );
      final errmsg = ErrorMsg();
      final plugin = extism.pluginNew(
        wasm,
        [fn1],
        true,
        errmsg,
      );
      final testData = 'test data';
      extism.pluginCallWithUserData(
        plugin,
        'count_vowels',
        testData.n,
      );
      final len = extism.pluginOutputLength(plugin);
      final output = extism.pluginOutputData(plugin);
      print('count_vowels result: len = $len, output = $output');
      extism.pluginFree(plugin);
      extism.extismFunctionFree(fn1);
      extism.logDrain(
        (String output, int len) => print('[log] len = $len, output = $output'),
      );
    });
  });
}
