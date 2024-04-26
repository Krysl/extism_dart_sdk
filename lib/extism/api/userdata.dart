import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'current_plugin.dart';
import 'types.dart';

typedef DartUserDataFunction = void Function(
  // FIXME: can not use currentPlugin in dart.
  ExtismCurrentPluginPtr currentPlugin,
  VoidPointer userdata,
);

// FIXME: The type is too rigid.
// should support most types
typedef UserDataFunction = ffi.Void Function(
  ExtismCurrentPluginPtr,
  VoidPointer,
);
typedef DartFinalizerFunction = ffi.Void Function(VoidPointer token);
// typedef DartFinalizerFunction = void Function(VoidPointer token);

// const _calloc = calloc;

class UserData<T extends ffi.NativeType> implements ffi.Finalizable {
  ffi.Pointer<T> _data;
  int length;
  VoidPointer get data => _data.cast();

  UserData._(this._data, this.length);

  static final UserData fake = UserData.fromString('Fake userData');

  factory UserData.allocate(
    int? count, {
    int? alignment,
  }) {
    final size = count ?? 1;
    final newdata = calloc.allocate<T>(size, alignment: alignment);
    final newUserData = UserData<T>._(newdata, size);
    _finalizer.attach(
      newUserData,
      newdata as VoidPointer,
      // externalSize: ffi.sizeOf<T>(), // todo:
      externalSize: count,
    );
    return newUserData;
  }

  /// code from [package:ffi toNativeUtf8](https://pub.dev/documentation/ffi/latest/ffi/StringUtf8Pointer/toNativeUtf8.html)
  static UserData<ffi.Uint8> fromString(String str) {
    final units = utf8.encode(str);
    final size = units.length + 1;
    final ffi.Pointer<ffi.Uint8> result = calloc.call<ffi.Uint8>(size);
    final Uint8List nativeString = result.asTypedList(
      size,
      finalizer: calloc.nativeFree,
    );
    nativeString.setAll(0, units);
    nativeString[units.length] = 0;
    return UserData<ffi.Uint8>._(result, size);
  }

  static final _finalizer = ffi.NativeFinalizer(calloc.nativeFree);
}

extension UserDataUint8AsTypedList on UserData<ffi.Uint8> {
  Uint8List asTypedList() => _data.asTypedList(length);
}
