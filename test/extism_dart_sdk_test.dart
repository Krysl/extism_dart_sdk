import 'dart:io';
import 'dart:ffi' as ffi;

import 'package:extism_dart_sdk/extism/generated_bindings.dart';
import 'package:extism_dart_sdk/extism_dart_sdk.dart';
import 'package:ffi/ffi.dart';
import 'package:test/test.dart';

void helloWorld(
    ffi.Pointer<ExtismCurrentPlugin> plugin,
    ffi.Pointer<ExtismVal> inputs,
    DartExtismSize n_inputs,
    ffi.Pointer<ExtismVal> outputs,
    DartExtismSize n_outputs,
    ffi.Pointer<ffi.Void> data) {
  print("Hello from Dart!");
}

void main() {
  group('Extism API tests', () {
    late final Extism extism;

    setUpAll(() {
      extism = Extism();
    });

    test('extismVersion', () {
      expect(extism.version, matches(r'\d+.\d+.\d+'));
    });

    test('test', () {
      // extism.logCustom("extism=trace,cranelift=trace");
      extism.logCustom("debug");
      final wasm = File("test/wasm/code-functions.wasm").readAsBytesSync();

      void helloWorld(
          ffi.Pointer<ExtismCurrentPlugin> plugin,
          ffi.Pointer<ExtismVal> inputs,
          DartExtismSize n_inputs,
          ffi.Pointer<ExtismVal> outputs,
          DartExtismSize n_outputs,
          ffi.Pointer<ffi.Void> data) {
        print("Hello from Dart Callback!");
        print(data.cast<Utf8>().toDartString());

        final ptrOffs = inputs[0].v.i64;

        final buf = extism.currentPluginMemory(plugin) + ptrOffs;
        final length = extism.currentPluginMemoryLength(plugin, ptrOffs);

        print(buf.toDartString());
      }

      void freeUserData(ffi.Pointer<ffi.Void> _) {}

      final fn1 = extism.functionNew(
        'hello_world',
        [ExtismValType.I64],
        [ExtismValType.I64],
        // helloWorld,
        ffi.NativeCallable.isolateLocal(helloWorld),
        "dart callback user data:Hello, again!".toNativeUtf8().cast(),
        freeUserData,
      );
      final errmsg = ErrorMsg();
      final plugin = extism.pluginNew(
        wasm,
        [fn1],
        true,
        errmsg,
      );
      final testData = "test data";
      extism.pluginCall(
        plugin,
        "count_vowels",
        testData.toNativeUtf8().cast(),
        testData.length,
      );
      final len = extism.pluginOutputLength(plugin);
      final output = extism.extismPluginOutputData(plugin);
      print("count_vowels result: len = $len, output = $output");
      extism.pluginFree(plugin);
      extism.extismFunctionFree(fn1);
      extism.logDrain(
        (String output, int len) => print("[log] len = $len, output = $output"),
      );
      final handle = extism.pluginCancelHandle(plugin);
      extism.pluginCancel(handle);
    });
  });
}
