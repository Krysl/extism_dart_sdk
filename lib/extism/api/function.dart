import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

import '../../extism_dart_sdk.dart';
import '../generated_bindings.dart';

final class HostFunction extends ffi.Struct {
  external ffi.Pointer<ffi.NativeFunction<UserDataFunction>> func;

  external VoidPointer userData;

  external ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer)>>
      freeUserData;
}

class HostFunctionFactory implements ffi.Finalizable {
  static final ffi.NativeFinalizer _finalizer = ffi.NativeFinalizer(
      ExtismApi.api.lib.addresses.extism_function_free.cast());

  ExtismFunctionPtr _func;
  String _name;
  late ffi.Pointer<HostFunction> _userData;
  HostFunctionFactory._(this._name, this._func, this._userData);

  factory HostFunctionFactory.newFunc(
      String name,
      List<ExtismValType> inputs,
      List<ExtismValType> outputs,
      DartUserDataFunction func,
      VoidPointer userData,
      void Function(VoidPointer _) freeUserData,
      {String? namespace}) {
    final inputsNum = inputs.length;
    final outputsNum = outputs.length;

    final ins = calloc.call<ffi.Int32>(inputsNum)
      ..asTypedList(inputsNum).setAll(0, inputs.toIterableInt());
    final outs = calloc.call<ffi.Int32>(outputsNum)
      ..asTypedList(outputsNum).setAll(0, outputs.toIterableInt());

    void freeData(VoidPointer _) {
      logger.d('freeData');
      // calloc.free(ins);
      // calloc.free(outs);
    }

    final userDataPtr = calloc.call<HostFunction>(1);
    userDataPtr.ref
      ..func =
          ffi.NativeCallable<UserDataFunction>.isolateLocal(func).nativeFunction
      ..userData = userData
      ..freeUserData =
          ffi.NativeCallable<ffi.Void Function(ffi.Pointer)>.isolateLocal(
                  freeUserData)
              .nativeFunction;

    void functionCallback(
      ExtismCurrentPluginPtr plugin,
      ffi.Pointer<ExtismVal> inputs,
      DartExtismSize inputsNum,
      ffi.Pointer<ExtismVal> outputs,
      DartExtismSize outputsNum,
      VoidPointer data,
    ) {
      final d = data.cast<HostFunction>();
      final fn = d.ref.func.asFunction<DartUserDataFunction>();
      final cp = CurrentPlugin(
        pointer: plugin,
        inputs: inputs,
        inputsNum: inputsNum,
        outputs: outputs,
        outputsNum: outputsNum,
      );

      fn(plugin, d.ref.userData);

      final strPtr = cp.inputUtf8String(0);
      // print('get currentPluginMemory: $strPtr');
      cp.outputString(strPtr, 0);
    }

    final ptr = ExtismApi.api.lib.extism_function_new(
      name.toNativeUtf8().cast(),
      ins,
      inputsNum,
      outs,
      outputsNum,
      ffi.NativeCallable<ExtismFunctionTypeFunction>.isolateLocal(
              functionCallback)
          .nativeFunction,
      userDataPtr.cast(),
      ffi.NativeCallable<ffi.Void Function(VoidPointer _)>.isolateLocal(
              freeData)
          .nativeFunction,
    );

    // finalizer
    final wrapper = HostFunctionFactory._(
      name,
      ptr,
      userDataPtr,
    );
    _finalizer.attach(wrapper, ptr.cast(), detach: wrapper);
    if (namespace != null) {
      ExtismApi.api.setNamespace(ptr, namespace);
    }
    return wrapper;
  }
  ExtismFunctionPtr get func => _func;

  bool _freed = false;
  void free() {
    if (_freed) {
      return;
    }
    _freed = true;
    _finalizer.detach(this);
    print('Function Freed');
  }
}
