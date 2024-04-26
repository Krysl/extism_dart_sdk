import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import '../../utils/extensions.dart';
import '../generated_bindings.dart';
import 'api.dart';
import 'buffer.dart';
import 'types.dart';

typedef ExtismCurrentPluginPtr = ffi.Pointer<ExtismCurrentPlugin>;

class CurrentPlugin extends CurrentPluginBase
    with CurrentPluginInputMixin, CurrentPluginOutputMixin {
  CurrentPlugin({
    required super.pointer,
    required super.inputs,
    required super.inputsNum,
    required super.outputs,
    required super.outputsNum,
  });
}

abstract class CurrentPluginBase {
  ExtismCurrentPluginPtr pointer;
  ffi.Pointer<ExtismVal> inputs;
  DartExtismSize inputsNum;
  ffi.Pointer<ExtismVal> outputs;
  DartExtismSize outputsNum;
  CurrentPluginBase({
    required this.pointer,
    required this.inputs,
    required this.inputsNum,
    required this.outputs,
    required this.outputsNum,
  });
  ExtismApi get api => ExtismApi.api;

  // Memory operations
  MemoryHandle memory({MemoryOffset offset = 0}) =>
      api.currentPluginMemory(pointer) + offset;

  MemoryOffset memoryAlloc(int size) =>
      api.currentPluginMemoryAlloc(pointer, size);

  void memoryFree(MemoryHandle handle) =>
      api.currentPluginMemoryFree(pointer, handle.address);

  MemoryHandle memoryLength({int offset = 0}) =>
      api.currentPluginMemoryLength(pointer, offset).cast();

  Buffer bufferAlloc(int size) {
    final ofst = memoryAlloc(size);
    return (memory(offset: ofst), size, ofst);
  }

  Buffer bufferCopy(CurrentPluginBase cp, Buffer buf) {
    final newBuf = bufferAlloc(buf.size);
    newBuf.writeBuffer(buf);
    return newBuf;
  }
}

mixin CurrentPluginInputMixin on CurrentPluginBase {
  Buffer inputBuffer(int index) {
    if (index >= inputsNum) {
      return (ffi.nullptr, -1, -1);
    }
    final inp = inputs[index];
    if (inp.t != ExtismValType.I64.val) {
      return (ffi.nullptr, -1, -1);
    }
    final ofst = inp.v.i64;
    final length = memoryLength(offset: ofst).address;

    return (memory(offset: ofst), length, ofst);
  }

  Uint8List inputUint8List(int index) => inputBuffer(index).asTypedList();

  ffi.Pointer<Utf8> inputUtf8Pointer(int index) =>
      inputBuffer(index).$1.cast<Utf8>();

  String inputUtf8String(int index) {
    final (ptr, len, _) = inputBuffer(index);
    return ptr.cast<Utf8>().toDartString(length: len);
  }

  ExtismVal intputVal(int index) {
    if (index >= inputsNum) {
      throw RangeError('Input out of bounds');
    }
    return inputs[index];
  }
}

mixin CurrentPluginOutputMixin on CurrentPluginBase {
  bool outputBuffer(Buffer srcbuf, int index) =>
      setOutputBuffer(index, bufferCopy(this, srcbuf));

  bool outputBytes(Uint8Ptr bytes, int len, int index) =>
      outputBuffer((bytes, len, -1), index);

  bool outputUint8List(Uint8List u8List, int index) => setOutputBuffer(
        index,
        bufferAlloc(u8List.length)..setAll(0, u8List),
      );

  bool outputString(String str, int index) {
    final s = str.toNativeUtf8();
    final list = s.cast<ffi.Uint8>().asTypedList(s.length);
    return outputUint8List(list, index);
  }

  ExtismVal outputVal(int index) {
    if (index >= outputsNum) {
      throw RangeError('Output out of bounds');
    }
    return outputs[index];
  }

  bool setOutputBuffer(int index, Buffer buf) {
    if (index >= outputsNum) {
      throw RangeError('Output out of bounds');
    }
    outputs[index].v.i64 = buf.ofst;
    return true;
  }
}
