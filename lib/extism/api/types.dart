// ignore_for_file: constant_identifier_names
import 'dart:ffi' as ffi;

class ExtismValType {
  final int val;

  const ExtismValType._(this.val);

  /// Signed 32 bit integer.
  static const I32 = ExtismValType._(0);

  /// Signed 64 bit integer.
  static const I64 = ExtismValType._(1);

  /// A wrapper around `ExtismValType.I64` to specify arguments that are pointers to memory blocks
  static const PTR = ExtismValType._(1);

  /// Floating point 32 bit integer.
  static const F32 = ExtismValType._(2);

  /// Floating point 64 bit integer.
  static const F64 = ExtismValType._(3);

  /// A 128 bit number.
  static const V128 = ExtismValType._(4);

  /// A reference to a Wasm function.
  static const FuncRef = ExtismValType._(5);

  /// A reference to opaque data in the Wasm instance.
  static const ExternRef = ExtismValType._(6);
}

extension To on List<ExtismValType> {
  // todo:
  Iterable<int> toIterableInt() => map((e) => e.val);
  List<int> toList() => toIterableInt().toList();
}

List<ExtismValType> l = [];

typedef VoidPointer = ffi.Pointer<ffi.Void>;
