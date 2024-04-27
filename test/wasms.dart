class WasmFiles {
  static const String _basePath = 'test/wasm';
  static const String wasm = '$_basePath/code-functions.wasm';

  /// from @extism/c-pdk/examples/host-functions/host-functions.c.
  /// 
  /// will call `hello_world`(host) in `count_vowels`(plugin)
  static const String wasmNoFunctions = '$_basePath/code.wasm';
  static const String wasmLoop = '$_basePath/loop.wasm';
  static const String wasmGlobals = '$_basePath/globals.wasm';
  static const String wasmReflect = '$_basePath/reflect.wasm';
  static const String wasmHttp = '$_basePath/http.wasm';
  static const String wasmFree = '$_basePath/free.wasm';
}
