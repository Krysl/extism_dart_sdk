import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data';

import 'package:option_result/option_result.dart';

import '../../utils/extensions.dart';
import '../../utils/log.dart';
import '../generated_bindings.dart';
import 'api.dart';
import 'buffer.dart';
import 'manifest.dart';
import 'userdata.dart';

typedef ExtismPluginPtr = ffi.Pointer<ExtismPlugin>;
typedef ExtismCancelHandlePtr = ffi.Pointer<ExtismCancelHandle>;
typedef ExtismFunctionPtr = ffi.Pointer<ExtismFunction>;

class CancelHandle {
  ExtismCancelHandlePtr handle;
  CancelHandle(this.handle);

  bool cancle() => ExtismApi.api.pluginCancel(handle);
}

final class ExtismCallError implements Error {
  /// Message describing the problem.
  final dynamic message;

  ExtismCallError(this.message);

  @override
  StackTrace? get stackTrace => null;

  @override
  String toString() => 'ExtismCallError(err: $message)';
}

final class ExtismPluginNewError implements Error {
  /// Message describing the problem.
  final dynamic message;

  ExtismPluginNewError(this.message);

  @override
  StackTrace? get stackTrace => null;

  @override
  String toString() => 'ExtismPluginNewError(err: $message)';
}

class Plugin {
  static late LibExtism _lib;

  List<ExtismFunctionPtr> functions;

  late ExtismPluginPtr _plugin;
  static final Finalizer<ExtismPluginPtr> _finalizer = Finalizer(
    (ExtismPluginPtr plugin) => _lib.extism_plugin_free(
      plugin,
    ),
  );

  void free() {
    _finalizer.detach(this);
    print('plugin freed');
  }

  Plugin(
    Uint8List wasm, {
    bool withWasi = false,
    this.functions = const [],
  }) {
    final errmsg = ErrorMsg();
    _plugin = ExtismApi.api.pluginNew(
      wasm,
      functions,
      true,
      errmsg,
    );
    final errPtr = errmsg.val.value;
    if (errPtr != ffi.nullptr) {
      final err = errPtr.cast<ffi.Uint8>().toDartString();
      ExtismApi.api.pluginNewErrorFree(errmsg);
      if (err.isNotEmpty) {
        throw ExtismPluginNewError(err);
      }
    }
  }

  factory Plugin.fromWasmFilePath(
    String wasmFilePath, {
    bool withWasi = false,
    List<ExtismFunctionPtr> functions = const [],
  }) =>
      Plugin(
        File(wasmFilePath).readAsBytesSync(),
        withWasi: withWasi,
        functions: functions,
      );

// FIXME:
  factory Plugin.fromManifest(
    Manifest manifest, {
    bool withWasi = false,
    List<ExtismFunctionPtr> functions = const [],
  }) {
    logger.d(manifest.toJsonString(indent: '  '));
    return Plugin(
      manifest.toJsonInUInt8List(),
      withWasi: withWasi,
      functions: functions,
    );
  }

  CancelHandle cancelHandle() =>
      CancelHandle(ExtismApi.api.pluginCancelHandle(_plugin));

  bool config(Map<String, String> config) =>
      ExtismApi.api.pluginConfig(_plugin, config);

  // Call a plugin
  Result<Buffer, Error> call(
      String functionName, Uint8Ptr input, int inputLength) {
    final api = ExtismApi.api;
    int rc = api.pluginCall(_plugin, functionName, input, inputLength);
    if (rc != 0) {
      final err = api.pluginError(_plugin);
      if (err.isNotEmpty) {
        return Err(ExtismCallError(err));
      }
    }
    final length = api.pluginOutputLength(_plugin);
    if (length < 0) {
      return Err(ExtismCallError(
          'call $functionName failed, output length = $length'));
    }
    final ptr = api.pluginOutputData(_plugin);
    if (ptr == ffi.nullptr) {
      return Err(ExtismCallError(
          'call $functionName failed, output data\'pointer = nullptr'));
    }
    return Ok((ptr.cast(), length, -1));
  }

// Call a plugin function with Uint8List input
  Result<Buffer, Error> callWithUint8List(
          String functionName, Uint8List input) =>
      call(functionName, input.allocatePointer(), input.length);

// Call a plugin function with string input
  Result<Buffer, Error> callWithString(String functionName, String input) {
    final userData = UserData.fromString(input);

    var result = call(
      functionName,
      userData.uint8Ptr,
      userData.length,
    );
    userData.free();
    return result;
  }

// Call a plugin function with native string buffer
  Result<Buffer, Error> callWithUint8Ptr(
          String functionName, Uint8Ptr input, int inputLength) =>
      call(functionName, input, inputLength);

// Returns true if the specified function exists
  bool functionExists(String functionName) =>
      ExtismApi.api.pluginFunctionExists(_plugin, functionName);

// Reset the Extism runtime, this will invalidate all allocated memory
// returns true if it succeeded
  bool reset() => ExtismApi.api.pluginReset(_plugin);
}
