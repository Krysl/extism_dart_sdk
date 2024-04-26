import 'dart:ffi';

import 'package:extism_dart_sdk/extism_dart_sdk.dart';
import 'package:ffi/ffi.dart';
import 'dylib_utils.dart';

typedef MyMalloc = VoidPointer Function(Int num, Int size);
typedef DartMyMalloc = VoidPointer Function(int num, int size);

typedef MyFree = Void Function(VoidPointer ptr);
typedef DartMyFree = void Function(VoidPointer ptr);

typedef LogCallback = Void Function(Uint8Ptr ptr);
typedef DartLogCallback = void Function(Uint8Ptr ptr);
typedef LogCallbackPtr = Pointer<NativeFunction<LogCallback>>;
typedef SetLog = Void Function(LogCallbackPtr callback);
typedef DartSetLog = void Function(LogCallbackPtr callback);
typedef GetVersion = Uint8Ptr Function();
typedef GetNotFreeNum = Uint32 Function();
typedef DartGetNotFreeNum = int Function();

final DynamicLibrary ffiMemoryTestFunctions =
    dlopenPlatformSpecific('memory', path: 'test/c/build/Debug/');

final myCalloc =
    ffiMemoryTestFunctions.lookupFunction<MyMalloc, DartMyMalloc>('myCalloc');

final myFreePtr =
    ffiMemoryTestFunctions.lookup<NativeFunction<MyFree>>('myFree');
final myFree = myFreePtr.asFunction<DartMyFree>();

final setCallocLogRaw =
    ffiMemoryTestFunctions.lookupFunction<SetLog, DartSetLog>('setCallocLog');

final setFreeLogRaw =
    ffiMemoryTestFunctions.lookupFunction<SetLog, DartSetLog>('setFreeLog');

void setCallocLog(DartLogCallback dartCallocLog) => setCallocLogRaw(
    NativeCallable<LogCallback>.isolateLocal(dartCallocLog).nativeFunction);
void setFreeLog(DartLogCallback dartFreeLog) => setFreeLogRaw(
    NativeCallable<LogCallback>.isolateLocal(dartFreeLog).nativeFunction);
void setLog({DartLogCallback? calloc, DartLogCallback? free}) {
  if (calloc != null) {
    setCallocLog(calloc);
  }
  if (free != null) {
    setFreeLog(free);
  }
}

final _getLibFreeVersion =
    ffiMemoryTestFunctions.lookupFunction<GetVersion, GetVersion>('version');

final getNotFreeNum = ffiMemoryTestFunctions
    .lookupFunction<GetNotFreeNum, DartGetNotFreeNum>('getNotFreeNum');

String getLibFreeVersion() => _getLibFreeVersion().cast<Utf8>().toDartString();

abstract class NativeFree {
  Pointer<NativeFinalizerFunction> get nativeFree;
}

abstract class FinalizableAllocator implements Allocator, NativeFree {}

class LibFreeApi implements FinalizableAllocator {
  LibFreeApi();
  @override
  final Pointer<NativeFunction<MyFree>> nativeFree = myFreePtr;

  @override
  Pointer<T> allocate<T extends NativeType>(int byteCount, {int? alignment}) =>
      myCalloc(byteCount, 1).cast();

  @override
  void free(Pointer<NativeType> pointer) {
    myFree(pointer.cast());
  }
}

class CallocAllocator2 implements FinalizableAllocator {
  @override
  Pointer<T> allocate<T extends NativeType>(int byteCount, {int? alignment}) =>
      calloc.allocate(byteCount);

  @override
  void free(Pointer<NativeType> pointer) => calloc.free(pointer);

  @override
  Pointer<NativeFinalizerFunction> get nativeFree => calloc.nativeFree;
}

extension ToHexString on int {
  String toHex() => '0x${toRadixString(16)}';
}
