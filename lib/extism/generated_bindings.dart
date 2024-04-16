// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint
import 'dart:ffi' as ffi;

class LibExtism {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  LibExtism(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  LibExtism.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  void __va_start(
    ffi.Pointer<va_list> arg0,
  ) {
    return ___va_start(
      arg0,
    );
  }

  late final ___va_startPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<va_list>)>>(
          '__va_start');
  late final ___va_start =
      ___va_startPtr.asFunction<void Function(ffi.Pointer<va_list>)>();

  void __security_init_cookie() {
    return ___security_init_cookie();
  }

  late final ___security_init_cookiePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function()>>(
          '__security_init_cookie');
  late final ___security_init_cookie =
      ___security_init_cookiePtr.asFunction<void Function()>();

  void __security_check_cookie(
    int _StackCookie,
  ) {
    return ___security_check_cookie(
      _StackCookie,
    );
  }

  late final ___security_check_cookiePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.UintPtr)>>(
          '__security_check_cookie');
  late final ___security_check_cookie =
      ___security_check_cookiePtr.asFunction<void Function(int)>();

  void __report_gsfailure(
    int _StackCookie,
  ) {
    return ___report_gsfailure(
      _StackCookie,
    );
  }

  late final ___report_gsfailurePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.UintPtr)>>(
          '__report_gsfailure');
  late final ___report_gsfailure =
      ___report_gsfailurePtr.asFunction<void Function(int)>();

  late final ffi.Pointer<ffi.UintPtr> ___security_cookie =
      _lookup<ffi.UintPtr>('__security_cookie');

  int get __security_cookie => ___security_cookie.value;

  set __security_cookie(int value) => ___security_cookie.value = value;

  /// Get a plugin's ID, the returned bytes are a 16 byte buffer that represent a UUIDv4
  ffi.Pointer<ffi.Uint8> extism_plugin_id(
    ffi.Pointer<ExtismPlugin> plugin,
  ) {
    return _extism_plugin_id(
      plugin,
    );
  }

  late final _extism_plugin_idPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Uint8> Function(
              ffi.Pointer<ExtismPlugin>)>>('extism_plugin_id');
  late final _extism_plugin_id = _extism_plugin_idPtr
      .asFunction<ffi.Pointer<ffi.Uint8> Function(ffi.Pointer<ExtismPlugin>)>();

  /// Returns a pointer to the memory of the currently running plugin
  /// NOTE: this should only be called from host functions.
  ffi.Pointer<ffi.Uint8> extism_current_plugin_memory(
    ffi.Pointer<ExtismCurrentPlugin> plugin,
  ) {
    return _extism_current_plugin_memory(
      plugin,
    );
  }

  late final _extism_current_plugin_memoryPtr = _lookup<
          ffi.NativeFunction<
              ffi.Pointer<ffi.Uint8> Function(
                  ffi.Pointer<ExtismCurrentPlugin>)>>(
      'extism_current_plugin_memory');
  late final _extism_current_plugin_memory =
      _extism_current_plugin_memoryPtr.asFunction<
          ffi.Pointer<ffi.Uint8> Function(ffi.Pointer<ExtismCurrentPlugin>)>();

  /// Allocate a memory block in the currently running plugin
  /// NOTE: this should only be called from host functions.
  int extism_current_plugin_memory_alloc(
    ffi.Pointer<ExtismCurrentPlugin> plugin,
    int n,
  ) {
    return _extism_current_plugin_memory_alloc(
      plugin,
      n,
    );
  }

  late final _extism_current_plugin_memory_allocPtr = _lookup<
      ffi.NativeFunction<
          ExtismMemoryHandle Function(ffi.Pointer<ExtismCurrentPlugin>,
              ExtismSize)>>('extism_current_plugin_memory_alloc');
  late final _extism_current_plugin_memory_alloc =
      _extism_current_plugin_memory_allocPtr
          .asFunction<int Function(ffi.Pointer<ExtismCurrentPlugin>, int)>();

  /// Get the length of an allocated block
  /// NOTE: this should only be called from host functions.
  int extism_current_plugin_memory_length(
    ffi.Pointer<ExtismCurrentPlugin> plugin,
    int n,
  ) {
    return _extism_current_plugin_memory_length(
      plugin,
      n,
    );
  }

  late final _extism_current_plugin_memory_lengthPtr = _lookup<
      ffi.NativeFunction<
          ExtismSize Function(ffi.Pointer<ExtismCurrentPlugin>,
              ExtismMemoryHandle)>>('extism_current_plugin_memory_length');
  late final _extism_current_plugin_memory_length =
      _extism_current_plugin_memory_lengthPtr
          .asFunction<int Function(ffi.Pointer<ExtismCurrentPlugin>, int)>();

  /// Free an allocated memory block
  /// NOTE: this should only be called from host functions.
  void extism_current_plugin_memory_free(
    ffi.Pointer<ExtismCurrentPlugin> plugin,
    int ptr,
  ) {
    return _extism_current_plugin_memory_free(
      plugin,
      ptr,
    );
  }

  late final _extism_current_plugin_memory_freePtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<ExtismCurrentPlugin>,
              ExtismMemoryHandle)>>('extism_current_plugin_memory_free');
  late final _extism_current_plugin_memory_free =
      _extism_current_plugin_memory_freePtr
          .asFunction<void Function(ffi.Pointer<ExtismCurrentPlugin>, int)>();

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
  ffi.Pointer<ExtismFunction> extism_function_new(
    ffi.Pointer<ffi.Char> name,
    ffi.Pointer<ffi.Int32> inputs,
    int n_inputs,
    ffi.Pointer<ffi.Int32> outputs,
    int n_outputs,
    ExtismFunctionType func,
    ffi.Pointer<ffi.Void> user_data,
    ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void> _)>>
        free_user_data,
  ) {
    return _extism_function_new(
      name,
      inputs,
      n_inputs,
      outputs,
      n_outputs,
      func,
      user_data,
      free_user_data,
    );
  }

  late final _extism_function_newPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ExtismFunction> Function(
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Int32>,
              ExtismSize,
              ffi.Pointer<ffi.Int32>,
              ExtismSize,
              ExtismFunctionType,
              ffi.Pointer<ffi.Void>,
              ffi.Pointer<
                  ffi.NativeFunction<
                      ffi.Void Function(
                          ffi.Pointer<ffi.Void> _)>>)>>('extism_function_new');
  late final _extism_function_new = _extism_function_newPtr.asFunction<
      ffi.Pointer<ExtismFunction> Function(
          ffi.Pointer<ffi.Char>,
          ffi.Pointer<ffi.Int32>,
          int,
          ffi.Pointer<ffi.Int32>,
          int,
          ExtismFunctionType,
          ffi.Pointer<ffi.Void>,
          ffi.Pointer<
              ffi
              .NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void> _)>>)>();

  /// Free `ExtismFunction`
  void extism_function_free(
    ffi.Pointer<ExtismFunction> f,
  ) {
    return _extism_function_free(
      f,
    );
  }

  late final _extism_function_freePtr = _lookup<
          ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ExtismFunction>)>>(
      'extism_function_free');
  late final _extism_function_free = _extism_function_freePtr
      .asFunction<void Function(ffi.Pointer<ExtismFunction>)>();

  /// Set the namespace of an `ExtismFunction`
  void extism_function_set_namespace(
    ffi.Pointer<ExtismFunction> ptr,
    ffi.Pointer<ffi.Char> namespace_,
  ) {
    return _extism_function_set_namespace(
      ptr,
      namespace_,
    );
  }

  late final _extism_function_set_namespacePtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<ExtismFunction>,
              ffi.Pointer<ffi.Char>)>>('extism_function_set_namespace');
  late final _extism_function_set_namespace =
      _extism_function_set_namespacePtr.asFunction<
          void Function(ffi.Pointer<ExtismFunction>, ffi.Pointer<ffi.Char>)>();

  /// Create a new plugin with host functions, the functions passed to this function no longer need to be manually freed using
  ///
  /// `wasm`: is a WASM module (wat or wasm) or a JSON encoded manifest
  /// `wasm_size`: the length of the `wasm` parameter
  /// `functions`: an array of `ExtismFunction*`
  /// `n_functions`: the number of functions provided
  /// `with_wasi`: enables/disables WASI
  ffi.Pointer<ExtismPlugin> extism_plugin_new(
    ffi.Pointer<ffi.Uint8> wasm,
    int wasm_size,
    ffi.Pointer<ffi.Pointer<ExtismFunction>> functions,
    int n_functions,
    bool with_wasi,
    ffi.Pointer<ffi.Pointer<ffi.Char>> errmsg,
  ) {
    return _extism_plugin_new(
      wasm,
      wasm_size,
      functions,
      n_functions,
      with_wasi,
      errmsg,
    );
  }

  late final _extism_plugin_newPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ExtismPlugin> Function(
              ffi.Pointer<ffi.Uint8>,
              ExtismSize,
              ffi.Pointer<ffi.Pointer<ExtismFunction>>,
              ExtismSize,
              ffi.Bool,
              ffi.Pointer<ffi.Pointer<ffi.Char>>)>>('extism_plugin_new');
  late final _extism_plugin_new = _extism_plugin_newPtr.asFunction<
      ffi.Pointer<ExtismPlugin> Function(
          ffi.Pointer<ffi.Uint8>,
          int,
          ffi.Pointer<ffi.Pointer<ExtismFunction>>,
          int,
          bool,
          ffi.Pointer<ffi.Pointer<ffi.Char>>)>();

  /// Free the error returned by `extism_plugin_new`, errors returned from `extism_plugin_error` don't need to be freed
  void extism_plugin_new_error_free(
    ffi.Pointer<ffi.Char> err,
  ) {
    return _extism_plugin_new_error_free(
      err,
    );
  }

  late final _extism_plugin_new_error_freePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Char>)>>(
          'extism_plugin_new_error_free');
  late final _extism_plugin_new_error_free = _extism_plugin_new_error_freePtr
      .asFunction<void Function(ffi.Pointer<ffi.Char>)>();

  /// Remove a plugin from the registry and free associated memory
  void extism_plugin_free(
    ffi.Pointer<ExtismPlugin> plugin,
  ) {
    return _extism_plugin_free(
      plugin,
    );
  }

  late final _extism_plugin_freePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ExtismPlugin>)>>(
          'extism_plugin_free');
  late final _extism_plugin_free = _extism_plugin_freePtr
      .asFunction<void Function(ffi.Pointer<ExtismPlugin>)>();

  /// Get handle for plugin cancellation
  ffi.Pointer<ExtismCancelHandle> extism_plugin_cancel_handle(
    ffi.Pointer<ExtismPlugin> plugin,
  ) {
    return _extism_plugin_cancel_handle(
      plugin,
    );
  }

  late final _extism_plugin_cancel_handlePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ExtismCancelHandle> Function(
              ffi.Pointer<ExtismPlugin>)>>('extism_plugin_cancel_handle');
  late final _extism_plugin_cancel_handle =
      _extism_plugin_cancel_handlePtr.asFunction<
          ffi.Pointer<ExtismCancelHandle> Function(
              ffi.Pointer<ExtismPlugin>)>();

  /// Cancel a running plugin
  bool extism_plugin_cancel(
    ffi.Pointer<ExtismCancelHandle> handle,
  ) {
    return _extism_plugin_cancel(
      handle,
    );
  }

  late final _extism_plugin_cancelPtr = _lookup<
          ffi
          .NativeFunction<ffi.Bool Function(ffi.Pointer<ExtismCancelHandle>)>>(
      'extism_plugin_cancel');
  late final _extism_plugin_cancel = _extism_plugin_cancelPtr
      .asFunction<bool Function(ffi.Pointer<ExtismCancelHandle>)>();

  /// Update plugin config values.
  bool extism_plugin_config(
    ffi.Pointer<ExtismPlugin> plugin,
    ffi.Pointer<ffi.Uint8> json,
    int json_size,
  ) {
    return _extism_plugin_config(
      plugin,
      json,
      json_size,
    );
  }

  late final _extism_plugin_configPtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<ExtismPlugin>, ffi.Pointer<ffi.Uint8>,
              ExtismSize)>>('extism_plugin_config');
  late final _extism_plugin_config = _extism_plugin_configPtr.asFunction<
      bool Function(ffi.Pointer<ExtismPlugin>, ffi.Pointer<ffi.Uint8>, int)>();

  /// Returns true if `func_name` exists
  bool extism_plugin_function_exists(
    ffi.Pointer<ExtismPlugin> plugin,
    ffi.Pointer<ffi.Char> func_name,
  ) {
    return _extism_plugin_function_exists(
      plugin,
      func_name,
    );
  }

  late final _extism_plugin_function_existsPtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<ExtismPlugin>,
              ffi.Pointer<ffi.Char>)>>('extism_plugin_function_exists');
  late final _extism_plugin_function_exists =
      _extism_plugin_function_existsPtr.asFunction<
          bool Function(ffi.Pointer<ExtismPlugin>, ffi.Pointer<ffi.Char>)>();

  /// Call a function
  ///
  /// `func_name`: is the function to call
  /// `data`: is the input data
  /// `data_len`: is the length of `data`
  int extism_plugin_call(
    ffi.Pointer<ExtismPlugin> plugin,
    ffi.Pointer<ffi.Char> func_name,
    ffi.Pointer<ffi.Uint8> data,
    int data_len,
  ) {
    return _extism_plugin_call(
      plugin,
      func_name,
      data,
      data_len,
    );
  }

  late final _extism_plugin_callPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<ExtismPlugin>, ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Uint8>, ExtismSize)>>('extism_plugin_call');
  late final _extism_plugin_call = _extism_plugin_callPtr.asFunction<
      int Function(ffi.Pointer<ExtismPlugin>, ffi.Pointer<ffi.Char>,
          ffi.Pointer<ffi.Uint8>, int)>();

  /// Get the error associated with a `Plugin`
  ffi.Pointer<ffi.Char> extism_error(
    ffi.Pointer<ExtismPlugin> plugin,
  ) {
    return _extism_error(
      plugin,
    );
  }

  late final _extism_errorPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(
              ffi.Pointer<ExtismPlugin>)>>('extism_error');
  late final _extism_error = _extism_errorPtr
      .asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ExtismPlugin>)>();

  /// Get the error associated with a `Plugin`
  ffi.Pointer<ffi.Char> extism_plugin_error(
    ffi.Pointer<ExtismPlugin> plugin,
  ) {
    return _extism_plugin_error(
      plugin,
    );
  }

  late final _extism_plugin_errorPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(
              ffi.Pointer<ExtismPlugin>)>>('extism_plugin_error');
  late final _extism_plugin_error = _extism_plugin_errorPtr
      .asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ExtismPlugin>)>();

  /// Get the length of a plugin's output data
  int extism_plugin_output_length(
    ffi.Pointer<ExtismPlugin> plugin,
  ) {
    return _extism_plugin_output_length(
      plugin,
    );
  }

  late final _extism_plugin_output_lengthPtr = _lookup<
          ffi.NativeFunction<ExtismSize Function(ffi.Pointer<ExtismPlugin>)>>(
      'extism_plugin_output_length');
  late final _extism_plugin_output_length = _extism_plugin_output_lengthPtr
      .asFunction<int Function(ffi.Pointer<ExtismPlugin>)>();

  /// Get a pointer to the output data
  ffi.Pointer<ffi.Uint8> extism_plugin_output_data(
    ffi.Pointer<ExtismPlugin> plugin,
  ) {
    return _extism_plugin_output_data(
      plugin,
    );
  }

  late final _extism_plugin_output_dataPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Uint8> Function(
              ffi.Pointer<ExtismPlugin>)>>('extism_plugin_output_data');
  late final _extism_plugin_output_data = _extism_plugin_output_dataPtr
      .asFunction<ffi.Pointer<ffi.Uint8> Function(ffi.Pointer<ExtismPlugin>)>();

  /// Set log file and level.
  /// The log level can be either one of: info, error, trace, debug, warn or a more
  /// complex filter like `extism=trace,cranelift=debug`
  /// The file will be created if it doesn't exist.
  bool extism_log_file(
    ffi.Pointer<ffi.Char> filename,
    ffi.Pointer<ffi.Char> log_level,
  ) {
    return _extism_log_file(
      filename,
      log_level,
    );
  }

  late final _extism_log_filePtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>)>>('extism_log_file');
  late final _extism_log_file = _extism_log_filePtr.asFunction<
      bool Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>)>();

  /// Enable a custom log handler, this will buffer logs until `extism_log_drain` is called
  /// Log level should be one of: info, error, trace, debug, warn
  bool extism_log_custom(
    ffi.Pointer<ffi.Char> log_level,
  ) {
    return _extism_log_custom(
      log_level,
    );
  }

  late final _extism_log_customPtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function(ffi.Pointer<ffi.Char>)>>(
          'extism_log_custom');
  late final _extism_log_custom =
      _extism_log_customPtr.asFunction<bool Function(ffi.Pointer<ffi.Char>)>();

  /// Calls the provided callback function for each buffered log line.
  /// This is only needed when `extism_log_custom` is used.
  void extism_log_drain(
    ExtismLogDrainFunctionType handler,
  ) {
    return _extism_log_drain(
      handler,
    );
  }

  late final _extism_log_drainPtr = _lookup<
          ffi.NativeFunction<ffi.Void Function(ExtismLogDrainFunctionType)>>(
      'extism_log_drain');
  late final _extism_log_drain = _extism_log_drainPtr
      .asFunction<void Function(ExtismLogDrainFunctionType)>();

  /// Reset the Extism runtime, this will invalidate all allocated memory
  bool extism_plugin_reset(
    ffi.Pointer<ExtismPlugin> plugin,
  ) {
    return _extism_plugin_reset(
      plugin,
    );
  }

  late final _extism_plugin_resetPtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function(ffi.Pointer<ExtismPlugin>)>>(
          'extism_plugin_reset');
  late final _extism_plugin_reset = _extism_plugin_resetPtr
      .asFunction<bool Function(ffi.Pointer<ExtismPlugin>)>();

  /// Get the Extism version string
  ffi.Pointer<ffi.Char> extism_version() {
    return _extism_version();
  }

  late final _extism_versionPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'extism_version');
  late final _extism_version =
      _extism_versionPtr.asFunction<ffi.Pointer<ffi.Char> Function()>();
}

typedef va_list = ffi.Pointer<ffi.Char>;

/// An enumeration of all possible value types in WebAssembly.
abstract class ExtismValType {
  /// Signed 32 bit integer.
  static const int I32 = 0;

  /// Signed 64 bit integer.
  static const int I64 = 1;

  /// Floating point 32 bit integer.
  static const int F32 = 2;

  /// Floating point 64 bit integer.
  static const int F64 = 3;

  /// A 128 bit number.
  static const int V128 = 4;

  /// A reference to a Wasm function.
  static const int FuncRef = 5;

  /// A reference to opaque data in the Wasm instance.
  static const int ExternRef = 6;
}

final class ExtismCancelHandle extends ffi.Opaque {}

final class ExtismCurrentPlugin extends ffi.Opaque {}

final class ExtismFunction extends ffi.Opaque {}

final class ExtismPlugin extends ffi.Opaque {}

/// A union type for host function argument/return values
final class ExtismValUnion extends ffi.Union {
  @ffi.Int32()
  external int i32;

  @ffi.Int64()
  external int i64;

  @ffi.Float()
  external double f32;

  @ffi.Double()
  external double f64;
}

/// `ExtismVal` holds the type and value of a function argument/return
final class ExtismVal extends ffi.Struct {
  @ffi.Int32()
  external int t;

  external ExtismValUnion v;
}

typedef ExtismMemoryHandle = ffi.Uint64;
typedef DartExtismMemoryHandle = int;
typedef ExtismSize = ffi.Uint64;
typedef DartExtismSize = int;

/// Host function signature
typedef ExtismFunctionType
    = ffi.Pointer<ffi.NativeFunction<ExtismFunctionTypeFunction>>;
typedef ExtismFunctionTypeFunction = ffi.Void Function(
    ffi.Pointer<ExtismCurrentPlugin> plugin,
    ffi.Pointer<ExtismVal> inputs,
    ExtismSize n_inputs,
    ffi.Pointer<ExtismVal> outputs,
    ExtismSize n_outputs,
    ffi.Pointer<ffi.Void> data);
typedef DartExtismFunctionTypeFunction = void Function(
    ffi.Pointer<ExtismCurrentPlugin> plugin,
    ffi.Pointer<ExtismVal> inputs,
    DartExtismSize n_inputs,
    ffi.Pointer<ExtismVal> outputs,
    DartExtismSize n_outputs,
    ffi.Pointer<ffi.Void> data);

/// Log drain callback
typedef ExtismLogDrainFunctionType
    = ffi.Pointer<ffi.NativeFunction<ExtismLogDrainFunctionTypeFunction>>;
typedef ExtismLogDrainFunctionTypeFunction = ffi.Void Function(
    ffi.Pointer<ffi.Char> data, ExtismSize size);
typedef DartExtismLogDrainFunctionTypeFunction = void Function(
    ffi.Pointer<ffi.Char> data, DartExtismSize size);

const int _VCRT_COMPILER_PREPROCESSOR = 1;

const int _SAL_VERSION = 20;

const int __SAL_H_VERSION = 180000000;

const int _USE_DECLSPECS_FOR_SAL = 0;

const int _USE_ATTRIBUTES_FOR_SAL = 0;

const int _CRT_PACKING = 8;

const int _VCRUNTIME_DISABLED_WARNINGS = 4514;

const int _HAS_EXCEPTIONS = 1;

const int _WCHAR_T_DEFINED = 1;

const int NULL = 0;

const int _HAS_CXX17 = 0;

const int _HAS_CXX20 = 0;

const int _HAS_CXX23 = 0;

const int _HAS_NODISCARD = 1;

const int INT8_MIN = -128;

const int INT16_MIN = -32768;

const int INT32_MIN = -2147483648;

const int INT64_MIN = -9223372036854775808;

const int INT8_MAX = 127;

const int INT16_MAX = 32767;

const int INT32_MAX = 2147483647;

const int INT64_MAX = 9223372036854775807;

const int UINT8_MAX = 255;

const int UINT16_MAX = 65535;

const int UINT32_MAX = 4294967295;

const int UINT64_MAX = -1;

const int INT_LEAST8_MIN = -128;

const int INT_LEAST16_MIN = -32768;

const int INT_LEAST32_MIN = -2147483648;

const int INT_LEAST64_MIN = -9223372036854775808;

const int INT_LEAST8_MAX = 127;

const int INT_LEAST16_MAX = 32767;

const int INT_LEAST32_MAX = 2147483647;

const int INT_LEAST64_MAX = 9223372036854775807;

const int UINT_LEAST8_MAX = 255;

const int UINT_LEAST16_MAX = 65535;

const int UINT_LEAST32_MAX = 4294967295;

const int UINT_LEAST64_MAX = -1;

const int INT_FAST8_MIN = -128;

const int INT_FAST16_MIN = -2147483648;

const int INT_FAST32_MIN = -2147483648;

const int INT_FAST64_MIN = -9223372036854775808;

const int INT_FAST8_MAX = 127;

const int INT_FAST16_MAX = 2147483647;

const int INT_FAST32_MAX = 2147483647;

const int INT_FAST64_MAX = 9223372036854775807;

const int UINT_FAST8_MAX = 255;

const int UINT_FAST16_MAX = 4294967295;

const int UINT_FAST32_MAX = 4294967295;

const int UINT_FAST64_MAX = -1;

const int INTPTR_MIN = -9223372036854775808;

const int INTPTR_MAX = 9223372036854775807;

const int UINTPTR_MAX = -1;

const int INTMAX_MIN = -9223372036854775808;

const int INTMAX_MAX = 9223372036854775807;

const int UINTMAX_MAX = -1;

const int PTRDIFF_MIN = -9223372036854775808;

const int PTRDIFF_MAX = 9223372036854775807;

const int SIZE_MAX = -1;

const int SIG_ATOMIC_MIN = -2147483648;

const int SIG_ATOMIC_MAX = 2147483647;

const int WCHAR_MIN = 0;

const int WCHAR_MAX = 65535;

const int WINT_MIN = 0;

const int WINT_MAX = 65535;

const int __bool_true_false_are_defined = 1;

const int false1 = 0;

const int true1 = 1;

const int EXTISM_SUCCESS = 0;

const int PTR = 1;