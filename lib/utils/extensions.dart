import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

typedef Uint8Ptr = Pointer<Uint8>;

extension ToDartString on Pointer<Uint8> {
  String toDartString({int? length}) =>
      cast<Utf8>().toDartString(length: length);
}

/// code modified from package:ffi-2.1.2/lib/src/utf8.dart
/// Extension method for converting a [String] to a `(Pointer<Utf8>, int)`.
extension StringUtf8Pointer on String {
  /// Creates a zero-terminated [Utf8] code-unit array from this String.
  ///
  /// If this [String] contains NUL characters, converting it back to a string
  /// using [Utf8Pointer.toDartString] will truncate the result if a length is
  /// not passed.
  ///
  /// Unpaired surrogate code points in this [String] will be encoded as
  /// replacement characters (U+FFFD, encoded as the bytes 0xEF 0xBF 0xBD) in
  /// the UTF-8 encoded result. See [Utf8Encoder] for details on encoding.
  ///
  /// Returns an [allocator]-allocated pointer to the result.
  (Pointer<Utf8>, int) toNativeUtf8Size({Allocator allocator = malloc}) {
    final units = utf8.encode(this);
    var length = units.length;
    final Pointer<Uint8> result = allocator<Uint8>(length + 1);
    final Uint8List nativeString = result.asTypedList(length + 1);
    nativeString.setAll(0, units);
    nativeString[length] = 0;
    return (result.cast(), length);
  }

  Uint8List toUint8List() {
    final (ptr, length) = toNativeUtf8Size();
    return ptr.cast<Uint8>().asTypedList(length);
  }
}
