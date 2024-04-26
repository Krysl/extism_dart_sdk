import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../generated_bindings.dart';
import 'current_plugin.dart';
import 'types.dart';

typedef MemoryOffset = int;

class ExtismApi {
  late ffi.DynamicLibrary dylib;
  static late LibExtism _lib;

  // TODO: hide _lib?
  LibExtism get lib => _lib;
  static final ExtismApi _singleton = ExtismApi._internal();

  static ExtismApi get api => _singleton;

  ExtismApi._internal() {
    var libraryPath =
        path.join(Directory.current.path, 'hello_library', 'libhello.so');
    if (Platform.isMacOS) {
      libraryPath =
          path.join(Directory.current.path, 'hello_library', 'libhello.dylib');
    } else if (Platform.isWindows) {
      libraryPath =
          path.join(Directory.current.path, 'assets/lib/windows', 'extism.dll');
    }
    dylib = ffi.DynamicLibrary.open(libraryPath);
    _lib = LibExtism(dylib);
  }

  /// Get a plugin's ID, the returned bytes are a 16 byte buffer that represent a UUIDv4
  UuidValue pluginId(
    ffi.Pointer<ExtismPlugin> plugin,
  ) {
    final uuid = _lib.extism_plugin_id(plugin).asTypedList(16);
    return UuidValue.fromByteList(uuid);
  }

  /// Returns a pointer to the memory of the currently running plugin
  /// NOTE: this should only be called from host functions.
  ffi.Pointer<ffi.Uint8> currentPluginMemory(
    ExtismCurrentPluginPtr plugin,
  ) =>
      _lib.extism_current_plugin_memory(plugin);

  /// Allocate a memory block in the currently running plugin
  /// NOTE: this should only be called from host functions.
  MemoryOffset currentPluginMemoryAlloc(
    ExtismCurrentPluginPtr plugin,
    int n,
  ) =>
      ffi.Pointer.fromAddress(_lib.extism_current_plugin_memory_alloc(
        plugin,
        n,
      )).address;

  /// Get the length of an allocated block
  /// NOTE: this should only be called from host functions.
  ffi.Pointer currentPluginMemoryLength(
    ExtismCurrentPluginPtr plugin,
    int n,
  ) =>
      ffi.Pointer.fromAddress(_lib.extism_current_plugin_memory_length(
        plugin,
        n,
      ));

  /// Free an allocated memory block
  /// NOTE: this should only be called from host functions.
  void currentPluginMemoryFree(
    ExtismCurrentPluginPtr plugin,
    int ptr,
  ) =>
      _lib.extism_current_plugin_memory_free(
        plugin,
        ptr,
      );

  /// Create a new host function
  ///
  /// Arguments
  /// - `name`: function name, this should be valid UTF-8
  /// - `inputs`: argument types
  /// - `n_inputs`: number of argument types
  /// - `outputs`: return types
  /// - `n_outputs`: number of return types
  /// - `func`: the function to call
  /// - `user_data`: a pointer that will be passed to the function when it's called
  /// this value should live as long as the function exists
  /// - `free_user_data`: a callback to release the `user_data` value when the resulting
  /// `ExtismFunction` is freed.
  ///
  /// Returns a new `ExtismFunction` or `null` if the `name` argument is invalid.
  ffi.Pointer<ExtismFunction> functionNew(
    String name,
    List<ExtismValType> inputs,
    List<ExtismValType> outputs,
    ffi.NativeCallable<ExtismFunctionTypeFunction> func,
    ffi.Pointer<ffi.Void> userData,
    void Function(ffi.Pointer<ffi.Void> _) freeUserData,
  ) {
    final inputsNum = inputs.length;
    final outputsNum = outputs.length;

    final ins = calloc.call<ffi.Int32>(inputsNum)
      ..asTypedList(inputsNum).setAll(0, inputs.toIterableInt());
    final outs = calloc.call<ffi.Int32>(outputsNum)
      ..asTypedList(outputsNum).setAll(0, outputs.toIterableInt());

    void freeData(ffi.Pointer<ffi.Void> _) {
      calloc.free(ins);
      calloc.free(outs);
    }

    return _lib.extism_function_new(
      name.toNativeUtf8().cast(),
      ins,
      inputsNum,
      outs,
      outputsNum,
      func.nativeFunction,
      userData,
      ffi.NativeCallable<
              ffi.Void Function(ffi.Pointer<ffi.Void> _)>.isolateLocal(freeData)
          .nativeFunction,
    );
  }

  /// Free `ExtismFunction`
  void extismFunctionFree(
    ffi.Pointer<ExtismFunction> f,
  ) =>
      _lib.extism_function_free(
        f,
      );

  /// Set the namespace of an `ExtismFunction`
  void setNamespace(
    ffi.Pointer<ExtismFunction> ptr,
    String namespace,
  ) =>
      _lib.extism_function_set_namespace(
        ptr,
        namespace.toNativeUtf8().cast(),
      );

  /// Create a new plugin with host functions, the functions passed to this function no longer need to be manually freed using
  ///
  /// `wasm`: is a WASM module (wat or wasm) or a JSON encoded manifest
  /// `wasm_size`: the length of the `wasm` parameter
  /// `functions`: an array of `ExtismFunction*`
  /// `n_functions`: the number of functions provided
  /// `with_wasi`: enables/disables WASI
  ffi.Pointer<ExtismPlugin> pluginNew(
    Uint8List wasm,
    List<ffi.Pointer<ExtismFunction>> functions,
    bool withWasi,
    ErrorMsg errmsg,
  ) {
    int wasmSize = wasm.length;
    int functionsNum = functions.length;
    final fns = calloc.call<ffi.Pointer<ExtismFunction>>(functionsNum);
    for (final (index, fn) in functions.indexed) {
      fns[index] = fn;
    }
    return _lib.extism_plugin_new(
      wasm.allocatePointer(),
      wasmSize,
      fns,
      functionsNum,
      withWasi,
      errmsg.val,
    );
  }

  /// Free the error returned by `extism_plugin_new`, errors returned from `extism_plugin_error` don't need to be freed
  void pluginNewErrorFree(
    ErrorMsg err,
  ) =>
      _lib.extism_plugin_new_error_free(
        err.val.value,
      );

  /// Remove a plugin from the registry and free associated memory
  void pluginFree(
    ffi.Pointer<ExtismPlugin> plugin,
  ) =>
      _lib.extism_plugin_free(
        plugin,
      );

  /// Get handle for plugin cancellation
  ffi.Pointer<ExtismCancelHandle> pluginCancelHandle(
    ffi.Pointer<ExtismPlugin> plugin,
  ) =>
      _lib.extism_plugin_cancel_handle(
        plugin,
      );

  /// Cancel a running plugin
  bool pluginCancel(
    ffi.Pointer<ExtismCancelHandle> handle,
  ) =>
      _lib.extism_plugin_cancel(
        handle,
      );

  /// Update plugin config values.
  bool pluginConfig(
    ffi.Pointer<ExtismPlugin> plugin,
    Map<String, String> jsonConfig,
  ) {
    int jsonSize = jsonConfig.length;
    ffi.Pointer<ffi.Uint8> json = jsonEncode(jsonConfig).toNativeUtf8().cast();
    return _lib.extism_plugin_config(
      plugin,
      json,
      jsonSize,
    );
  }

  /// Returns true if `func_name` exists
  bool pluginFunctionExists(
    ffi.Pointer<ExtismPlugin> plugin,
    String functionName,
  ) {
    ffi.Pointer<ffi.Char> funcName = functionName.toNativeUtf8().cast();
    return _lib.extism_plugin_function_exists(
      plugin,
      funcName,
    );
  }

  /// Call a function
  ///
  /// `func_name`: is the function to call
  /// `data`: is the input data
  /// `data_len`: is the length of `data`
  int pluginCall(
    ffi.Pointer<ExtismPlugin> plugin,
    String functionName,
    ffi.Pointer<ffi.Uint8> data,
    int dataLen,
  ) {
    ffi.Pointer<ffi.Char> funcName = functionName.toNativeUtf8().cast();
    return _lib.extism_plugin_call(
      plugin,
      funcName,
      data,
      dataLen,
    );
  }

  /// Get the error associated with a `Plugin`
  String error(
    ffi.Pointer<ExtismPlugin> plugin,
  ) =>
      _lib
          .extism_error(
            plugin,
          )
          .cast<Utf8>()
          .toDartString();

  /// Get the error associated with a `Plugin`
  String pluginError(
    ffi.Pointer<ExtismPlugin> plugin,
  ) {
    final err = _lib
        .extism_plugin_error(
          plugin,
        )
        .cast<Utf8>();
    if (err.address != 0 && err.length > 0) return err.toDartString();

    return '';
  }

  /// Get the length of a plugin's output data
  int pluginOutputLength(
    ffi.Pointer<ExtismPlugin> plugin,
  ) =>
      _lib.extism_plugin_output_length(
        plugin,
      );

  /// Get a pointer to the output data
  ffi.Pointer pluginOutputData(
    ffi.Pointer<ExtismPlugin> plugin,
  ) =>
      _lib.extism_plugin_output_data(
        plugin,
      );

  /// Set log file and level.
  /// The log level can be either one of: info, error, trace, debug, warn or a more
  /// complex filter like `extism=trace,cranelift=debug`
  /// The file will be created if it doesn't exist.
  bool logFile(
    String filename,
    String logLevel,
  ) =>
      _lib.extism_log_file(
        filename.toNativeUtf8().cast(),
        logLevel.toNativeUtf8().cast(),
      );

  /// Enable a custom log handler, this will buffer logs until `extism_log_drain` is called
  /// Log level should be one of: info, error, trace, debug, warn
  bool logCustom(
    String logLevel,
  ) =>
      _lib.extism_log_custom(
        logLevel.toNativeUtf8().cast(),
      );

  /// Calls the provided callback function for each buffered log line.
  /// This is only needed when `extism_log_custom` is used.
  void logDrain(
    Function(String, int) handler,
  ) {
    void cb(ffi.Pointer<ffi.Char> data, int size) {
      handler(data.cast<Utf8>().toDartString(), size);
    }

    return _lib.extism_log_drain(
      ffi.NativeCallable<ExtismLogDrainFunctionTypeFunction>.isolateLocal(cb)
          .nativeFunction,
    );
  }

  /// Reset the Extism runtime, this will invalidate all allocated memory
  bool pluginReset(
    ffi.Pointer<ExtismPlugin> plugin,
  ) =>
      _lib.extism_plugin_reset(
        plugin,
      );

  /// Get the Extism version string
  String get version => _lib.extism_version().cast<Utf8>().toDartString();
}

class ErrorMsg {
  final ffi.Pointer<ffi.Pointer<ffi.Char>> val;
  ErrorMsg() : val = calloc();
}

extension Uint8ListBlobConversion on Uint8List {
  /// Allocates a pointer filled with the Uint8List data.
  ffi.Pointer<ffi.Uint8> allocatePointer() {
    final blob = calloc<ffi.Uint8>(length);
    final blobBytes = blob.asTypedList(length);
    blobBytes.setAll(0, this);
    return blob;
  }
}
