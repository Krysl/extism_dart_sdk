import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

import '../../extism_dart_sdk.dart';
import '../generated_bindings.dart';

typedef FreeFunction = ffi.Void Function(ffi.Pointer<ffi.Void>);

extension ToNativeCallable on void Function(VoidPointer _) {
  ffi.NativeCallable<ffi.Void Function(VoidPointer _)> get nativeCallable =>
      ffi.NativeCallable.isolateLocal(this);
  ffi.Pointer<ffi.NativeFunction<ffi.Void Function(VoidPointer _)>>
      get nativeFunction => nativeCallable.nativeFunction;
}

extension ToNativeCallable2 on DartExtismFunctionTypeFunction {
  ffi.NativeCallable<ExtismFunctionTypeFunction> get nativeCallable =>
      ffi.NativeCallable<ExtismFunctionTypeFunction>.isolateLocal(this);

  ffi.Pointer<ffi.NativeFunction<ExtismFunctionTypeFunction>>
      get nativeFunction => nativeCallable.nativeFunction;
}

/// *Advanced(not raw) Host Function* box
final class HostFunctionBox extends ffi.Struct {
  external ffi.Pointer<ffi.NativeFunction<UserDataFunction>> func;

  external VoidPointer userData;

  external ffi.Pointer<ffi.NativeFunction<FreeFunction>> freeUserData;

  DartUserDataFunction get asDartFunction => func.asFunction();

  void run(CurrentPluginPtr plugin) {
    asDartFunction(plugin, userData);
  }
}

class HostFunctionFactory implements ffi.Finalizable {
  static final ffi.NativeFinalizer _finalizer = ffi.NativeFinalizer(
      ExtismApi.api.lib.addresses.extism_function_free.cast());

  ExtismFunctionPtr _func;

  HostFunctionFactory._(this._func);

  /// *Advanced Host Function* creater
  factory HostFunctionFactory.newFunc(
      String name,
      List<ExtismValType> inputs,
      List<ExtismValType> outputs,
      DartUserDataFunction func,
      VoidPointer userData,
      void Function(VoidPointer _) freeUserData,
      {String? namespace}) {
    final userDataPtr = calloc.call<HostFunctionBox>(1);
    userDataPtr.ref
      ..func =
          ffi.NativeCallable<UserDataFunction>.isolateLocal(func).nativeFunction
      ..userData = userData
      ..freeUserData = freeUserData.nativeFunction;

    void hostFunctionWrapper(
      ExtismCurrentPluginPtr plugin,
      ffi.Pointer<ExtismVal> inputs,
      DartExtismSize inputsNum,
      ffi.Pointer<ExtismVal> outputs,
      DartExtismSize outputsNum,
      VoidPointer box,
    ) {
      final cpPtr = calloc.call<CurrentPlugin>();
      cpPtr.ref
        ..plugin = plugin
        ..inputs = inputs
        ..inputsNum = inputsNum
        ..outputs = outputs
        ..outputsNum = outputsNum;
      box.cast<HostFunctionBox>().ref.run(cpPtr);
      calloc.free(cpPtr);
    }

    void freeData(VoidPointer _) {
      logger.d('freeData'); // todo: using this to free?
    }

    final rawHostFunctionPtr = ExtismApi.api.lib.extism_function_new(
      name.n.charPtr,
      inputs.n.dataPtr,
      inputs.length,
      outputs.n.dataPtr,
      outputs.length,
      hostFunctionWrapper.nativeFunction,
      userDataPtr.cast(),
      freeData.nativeFunction,
    );

    // finalizer
    final wrapper = HostFunctionFactory._(rawHostFunctionPtr);
    _finalizer.attach(wrapper, rawHostFunctionPtr.cast(), detach: wrapper);
    if (namespace != null) {
      ExtismApi.api.setNamespace(rawHostFunctionPtr, namespace);
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
