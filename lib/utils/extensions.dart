import 'dart:ffi';

import 'package:ffi/ffi.dart';

extension ToDartString on Pointer<Uint8> {
  toDartString() => cast<Utf8>().toDartString();
}
