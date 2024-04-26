// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//
// SharedObjects=ffi_test_functions

import 'dart:async';
import 'dart:ffi';

import 'package:extism_dart_sdk/extism_dart_sdk.dart';
import 'package:test/test.dart';

import 'libfree.dart';

void darLogBase(
  Uint8Ptr ptr,
  String regex, [
  void Function(int addr)? callback,
]) {
  var str = ptr.toDartString();
  print(str);
  final match = RegExp(regex).firstMatch(str);
  final ptrString = match?.namedGroup('ptr');
  if (ptrString != null) {
    final addr = int.parse(ptrString);
    expect(ptrString, equals('0x${addr.toRadixString(16)}'));
    callback?.call(addr);
  }
}

void dartCallocLog(Uint8Ptr ptr) => darLogBase(
      ptr,
      r'\[C\] myCalloc num:(?<num>\d+), size:(?<size>\d+), ptr:(?<ptr>0x[0-9a-f]+)',
    );

void dartFreeLog(Uint8Ptr ptr) => darLogBase(
      ptr,
      r'\[C\] myFree ptr:(?<ptr>0x[0-9a-f]+)',
    );

void main() {
  group('group name', () {
    test('test lib version', () {
      final version = getLibFreeVersion();
      print('libfree version $version');
      expect(version, matches(r'\d+\.\d+\.\d+'));
    });
    test('testMallocFree', () async {
      await testMallocFree();
      print('end of test, shutting down');

      expect(remains(), inInclusiveRange(0, 2));
    });
  });
}

Future<void> testMallocFree([
  FutureOr<void> Function()? doGC,
  FinalizableAllocator? api,
]) async {
  api ??= LibFreeApi();
  // api ??= CallocAllocator2();
  setLog(
    calloc: dartCallocLog,
    // free: dartFreeLog, // can not call dart callback in Finalizer callback
  );

  {
    final resource = MyNativeResource(api);
    resource.close(); // check free works
    print('--- before gc 1 ---');
    doGC != null ? await doGC.call() : null;
    // no free auto called
  }

  {
    MyNativeResource(api);
    print('--- before gc 2 ---');
    doGC != null ? await doGC.call() : null;
  }

  // Run finalizer on shutdown (or on a GC that runs before shutdown).
  MyNativeResource(api);
}

int remains() {
  var num = getNotFreeNum();
  print('remain ptr num = $num');
  return num;
}

class MyNativeResource implements Finalizable {
  final Pointer<Void> pointer;
  final FinalizableAllocator api;

  bool _closed = false;

  MyNativeResource._(this.api, this.pointer, {int? externalSize}) {
    print('           pointer $pointer');

    final addr = api.nativeFree.address;
    var freeFinalizer = freeFinalizerMap[addr];

    freeFinalizer ??= freeFinalizerMap[addr] = NativeFinalizer(api.nativeFree);

    freeFinalizer.attach(this, pointer,
        externalSize: externalSize, detach: this);
  }

  factory MyNativeResource(FinalizableAllocator api) {
    const num = 1;
    const size = 16;
    final pointer = api.allocate(num * size).cast<Void>();
    return MyNativeResource._(api, pointer, externalSize: size);
  }

  /// Eagerly stop using the native resource. Cancelling the finalizer.
  void close() {
    print('close: ptr: ${pointer.address.toHex()}');
    _closed = true;
    freeFinalizerMap[api.nativeFree.address]?.detach(this);
    api.free(pointer);
  }

  void useResource() {
    if (_closed) {
      throw UnsupportedError('The native resource has already been released');
    }
    print(pointer.address);
  }
}

final freeFinalizerMap = <int, NativeFinalizer>{};
