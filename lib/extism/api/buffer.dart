import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:option_result/option_result.dart';

typedef MemoryHandle = ffi.Pointer<ffi.Uint8>;
typedef Buffer = (MemoryHandle, int size, int ofst);

extension BufferAsTypedList on Buffer {
  MemoryHandle get ptr => $1;
  int get size => $2;
  int get ofst => $3;

  Uint8List asTypedList() => ptr.asTypedList(size);
  int asInt() => ptr.cast<ffi.Uint32>().value;

  String toDartString() => ptr.cast<Utf8>().toDartString();

  void setAll(int index, Iterable<int> iterable) =>
      asTypedList().setAll(index, iterable);

  void writeUint8List(Uint8List src) => setAll(0, src);

  void writeBuffer(Buffer buf) => writeUint8List(buf.asTypedList());
}

extension StringToJsonMap on String {
  Map<String, dynamic> toJsonMap() => jsonDecode(this) as Map<String, dynamic>;
}

extension BufferToJsonMap on Buffer {
  Map<String, dynamic> toJsonMap() => toDartString().toJsonMap();
}

extension ResultToJsonMap on Result<Buffer, Error> {
  Map<String, dynamic> toJsonMap() => inspectErr((e) => throw e)
      .inspect((buf) {
        if (buf.size <= 0) {
          throw UnsupportedError(
              'Buffer size ${buf.size}, can not convern to json');
        }
      })
      .unwrap()
      .toJsonMap();
}
