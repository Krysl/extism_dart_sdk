import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:extism_dart_sdk/extism_dart_sdk.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:test/test.dart';
import 'package:toml/toml.dart';

// ignore: library_prefixes
import '../../wasms.dart';
import '../utils/log.dart';

part 'runtime_test.freezed.dart';
part 'runtime_test.g.dart';

@freezed
class Count with _$Count {
  const factory Count({
    required int count,
  }) = _Count;
  factory Count.fromJson(Map<String, dynamic> json) => _$CountFromJson(json);
}

// Code ported from:  https://github.com/extism/extism/blob/main/runtime/src/tests/runtime.rs

void helloWorld(
  CurrentPluginPtr currentPlugin,
  VoidPointer userdata,
) {
  final cp = currentPlugin.ref;
  final buf = cp.inputBuffer(0);
  cp.outputBuffer(buf, 0);
}

void helloWorldPanic(
  CurrentPluginPtr currentPlugin,
  VoidPointer userdata,
) {
  throw StateError('This should not run');
}

void main() {
  late final ExtismApi extism;
  final log = logger;

  setUpAll(() {
    extism = ExtismApi.api;
    expect(extism.version, matches(r'\d+.\d+.\d+'));
  });

  //code ported from tests/runtime.rs
  group('it works', () {
    late final Plugin plugin;
    final wasmStart = Stopwatch()..start();
    bool setedUP = false;
    setUp(() {
      if (setedUP) return;
      setedUP = true;
      // extism.logCustom('debug');//
      // extism.logCustom('extism=trace,cranelift=trace');
      extism.logFile(currentLogFilePath(), 'trace');

      final f = HostFunctionFactory.newFunc(
        'hello_world',
        [ExtismValType.PTR],
        [ExtismValType.PTR],
        helloWorld,
        UserData.fake.voidPtr,
        (_) {},
        namespace: 'extism:host/user',
      );
      final g = HostFunctionFactory.newFunc(
        'hello_world',
        [ExtismValType.PTR],
        [ExtismValType.PTR],
        helloWorldPanic,
        UserData.fake.voidPtr,
        (_) {},
        namespace: 'test',
      );

      plugin = Plugin.fromManifest(
        Manifest.path(WasmFiles.wasm),
        functions: [f.func, g.func], // todo:
        withWasi: true,
      );

      log.i('register loaded plugin: ${wasmStart.elapsed.inMilliseconds} ms');
    });
    final repeat = 1182;
    final str =
        'aeiouAEIOU____________________________________&smtms_y?' * repeat;
    test('count_vowels ', () {
      final result = plugin
          .callWithString(
            'count_vowels',
            str,
          )
          .toJsonMap();
      final count = Count.fromJson(result);
      expect(count.count, equals(11820));
      log.i(
          'register plugin + function call: ${wasmStart.elapsed.inMilliseconds} ms, sent input size: ${str.length} bytes');
    });

    test('[Performance test] native_test', () {
      final testTimes = <Duration>[];

      final testStart = Stopwatch()..start();
      for (var i = 0; i < 100; i++) {
        testStart.reset();
        plugin
            .callWithString(
              'count_vowels',
              str,
            )
            .unwrap()
            .toDartString();
        testTimes.add(testStart.elapsed);
      }
      final nativeStart = Stopwatch()..start();
      final chA = 'A'.codeUnitAt(0);
      final chE = 'E'.codeUnitAt(0);
      final chI = 'I'.codeUnitAt(0);
      final chO = 'O'.codeUnitAt(0);
      final chU = 'U'.codeUnitAt(0);
      final cha = 'a'.codeUnitAt(0);
      final che = 'e'.codeUnitAt(0);
      final chi = 'i'.codeUnitAt(0);
      final cho = 'o'.codeUnitAt(0);
      final chu = 'u'.codeUnitAt(0);
      Duration nativeTest() {
        nativeStart.reset();
        // ignore: unused_local_variable
        int count = 0;
        final input = str.codeUnits;
        for (final i in input) {
          if (i == chA ||
              i == chE ||
              i == chI ||
              i == chO ||
              i == chU ||
              i == cha ||
              i == che ||
              i == chi ||
              i == cho ||
              i == chu) {
            count += 1;
          }
        }
        return nativeStart.elapsed;
      }

      final nativeTestTimes = List.generate(100, (index) => nativeTest());

      final nativeNumTests = nativeTestTimes.length;
      final nativeSum =
          nativeTestTimes.reduce((value, element) => value + element);
      final nativeAvg =
          Duration(microseconds: nativeSum.inMicroseconds ~/ nativeNumTests);

      print('native function call (avg, N = $nativeNumTests): $nativeAvg');
      final numTest = testTimes.length;
      final sum = testTimes.reduce((value, element) => value + element);
      final avg = Duration(microseconds: sum.inMicroseconds ~/ numTest);

      print('wasm function call (avg, N = $numTest): $avg');

      print('wasm/native = ${avg.inMicroseconds / nativeAvg.inMicroseconds}');
    });

    test('test plugin isolates', () async {
      final isolates = <Future<Isolate>>[];
      final ports = List.generate(
        3,
        (index) => ReceivePort('port[$index]'),
      );
      final completers = List.generate(
        3,
        (index) => Completer(),
      );

      void entryPoint((SendPort, int) args) {
        final (sendPort, i) = args;

        print('#$i');
        final plugin = Plugin.fromManifest(
          Manifest.path(WasmFiles.wasmNoFunctions),
          withWasi: true,
        );
        final result = plugin
            .callWithString(
              'count_vowels',
              'this is a test aaa',
            )
            .toJsonMap();

        final {'count': count as int} = result;
        sendPort.send(count);
      }

      for (var i = 0; i < 3; i++) {
        final recvPort = ports[i];
        recvPort.listen(
          (result) {
            print('?> $i, $result');
            completers[i].complete(result);
            recvPort.close();
          },
        );
        final isolate = Isolate.spawn(
          entryPoint,
          (recvPort.sendPort, i),
          debugName: 'isolate[$i]',
          onExit: recvPort.sendPort,
          onError: recvPort.sendPort,
        );

        isolates.add(isolate);
      }

      final results = await Future.wait(completers.map((e) => e.future));
      for (final (index, result) in results.indexed) {
        expect(
          result,
          equals(7),
          reason: 'result in isolate[$index]',
        );
      }
    });

    test('test cancel', () async {
      final f = HostFunctionFactory.newFunc(
        'hello_world',
        [ExtismValType.PTR],
        [ExtismValType.PTR],
        helloWorld,
        UserData.fake.voidPtr,
        (_) {},
        namespace: 'extism:host/user',
      );
      final plugin = Plugin.fromManifest(
        Manifest.path(WasmFiles.wasmLoop),
        functions: [f.func],
        withWasi: true,
      );
      final handle = plugin.cancelHandle();
      final isolates = <Future<Isolate>>[];
      final port = ReceivePort();
      port.listen((message) {
        print('?> $message');
        if (message is String && message.startsWith('stop ')) {
          handle.cancle();
        }
      });
      // ignore: dead_code
      for (var i = 0; i < 5; i++) {
        final startTime = Stopwatch()..start();
        void entry((int, SendPort) args) {
          final (index, sendPort) = args;
          sendPort.send('in isolate $index');
          print('wait isolate $index');
          sleep(Duration(seconds: 1));
          print('cancle isolate $index');
          sendPort.send('stop $index');
        }

        print('start isolate $i');
        isolates.add(Isolate.spawn(
          entry,
          (i, port.sendPort),
          debugName: 'isolate[$i]',
          onExit: port.sendPort,
          onError: port.sendPort,
        ));

        ///  FIXME: ffi block function will block all!!!
        /// [Allow Ffi calls to be marked as potentially blocking / exiting the isolate.](@dart-lang/sdk#51261)
        /// ? can i make it as a plugin, so we can wrap the call
        throw Exception('''
        FixMe: ffi cals should not block, except using Dart_ExitIsolate api in C.
            see https://github.com/dart-lang/sdk/issues/51261 for details.
        ''');
        // ignore: dead_code
        final _ = plugin.callWithString('loop_forever', 'abc123');

        print('Cancelled plugin ran for ${startTime.elapsedMicroseconds} us');
      }
      await Future.wait(isolates);
    });

    test('test timeout', () {
      final plugin = Plugin.fromManifest(
        Manifest.path(WasmFiles.wasmLoop)
          ..withTimeout(
            Duration(seconds: 1),
          ),
        withWasi: true,
      );
      final startTime = Stopwatch()..start();
      final output = plugin.callWithString('loop_forever', 'abc123');
      print(
          'Timed out plugin ran for ${startTime.elapsed}, with error: ${output.unwrapErr()}');
    });

    // todo: [test_typed_plugin_macro] use codegen?

    test('test multiple instantiations', () {
      final plugin = Plugin.fromManifest(
        Manifest.path(WasmFiles.wasmNoFunctions),
        withWasi: true,
      );
      final num = 10001;
      final str = 'abc123';
      int result = List.generate(
        num,
        (index) => Count.fromJson(
          plugin
              .callWithString(
                'count_vowels',
                str,
              )
              .inspectErr((e) {
                throw e;
              })
              .unwrap()
              .toJsonMap(),
        ).count,
      ).fold(0, (previousValue, element) => previousValue + element);
      print('$num instance count_vowels for $str with sum $result');
      expect(result, equals(num * 1));
    });
    test('test globals', () {
      final startTime = Stopwatch()..start();
      final plugin = Plugin.fromManifest(
        Manifest.path(WasmFiles.wasmGlobals),
      );
      final num = 100000;
      List.generate(num, (index) {
        final {'count': count} = plugin
            .callWithString(
              'globals',
              '',
            )
            .inspectErr((e) {
              throw e;
            })
            .unwrap()
            .toJsonMap();
        expect(count, index);
      });
      print('$num test takes ${startTime.elapsed}');
    });

    test('test toml manifest', () {
      final manifest = Manifest.path(WasmFiles.wasmNoFunctions)
        ..withTimeout(Duration(seconds: 1));
      final manifestString = manifest.toJsonString();
      print(manifestString);
      final manifestToml = TomlDocument.fromMap(jsonDecode(
        manifestString,
      ) as Map);
      final plugin = Plugin(
        manifestToml.toString().toUint8List(),
        withWasi: true,
      );
      final {'count': count} = plugin
          .callWithString(
            'count_vowels',
            'abc123',
          )
          .inspectErr((e) {
            throw e;
          })
          .unwrap()
          .toJsonMap();
      expect(count, equals(1));
    });
    test('test fuzz reflect plugin', () {
      final f = HostFunctionFactory.newFunc(
        'host_reflect',
        [ExtismValType.PTR],
        [ExtismValType.PTR],
        helloWorld,
        UserData.fake.voidPtr,
        (_) {},
        namespace: 'extism:host/user',
      );
      final plugin = Plugin.fromManifest(
        Manifest.path(WasmFiles.wasmReflect),
        functions: [f.func],
      );
      final totalStartTime = Stopwatch()..start();
      final startTime = Stopwatch()..start();
      final num = 30000;
      int? startSpeed;
      int lastSpeed = 0;
      int preIndex = 0;
      List.generate(num, (index) {
        final input = 'a' * index;
        final output =
            plugin.callWithString('reflect', input).unwrap().toDartString();

        expect(output, input);
        if (startTime.elapsedMilliseconds > 1000) {
          startTime.reset();
          // FIXME: getting slower and slower
          lastSpeed = index - preIndex;
          startSpeed ??= lastSpeed;
          print('${totalStartTime.elapsed} '
              '$index ${(index / num * 100).toStringAsFixed(2)}%, '
              '${index - preIndex}/s,'
              'remaining ${num - index} '
              '${((num - index) / lastSpeed).toStringAsFixed(2)}s');
          preIndex = index;
        }
      });
      sleep(Duration(seconds: 5));
      expect(
        lastSpeed / startSpeed!,
        inInclusiveRange(0.5, double.infinity),
      );
    });

    test('test memory max', () {
      {
        final plugin = Plugin.fromManifest(
          Manifest.path(WasmFiles.wasmNoFunctions)
            ..memoryMax = 16
            ..withTimeout(Duration(seconds: 5)),
          withWasi: true,
        );
        final output = plugin.callWithString(
          'count_vowels',
          'a' * (65536 * 2),
        );
        expect(output.isErr(), isTrue);
        // FIXME: no oom err back
        final err = output.expectErr('should be err: oom');
        expect(
            err,
            isA<ExtismPluginNewError>().having(
              (e) => e.message,
              'should be oom',
              equals('oom'),
            ));
        print((output.unwrapErr() as ExtismPluginNewError).message);
      }
      {
        final plugin = Plugin.fromManifest(
          Manifest.path(WasmFiles.wasmNoFunctions)..memoryMax = 17,
          withWasi: true,
        );
        final output = plugin.callWithString(
          'count_vowels',
          'a' * (65536 * 2),
        );
        expect(output.isOk(), isTrue);
        final {'count': count} = output.unwrap().toJsonMap();
        print('#2 count = $count');
      }
      {
        final plugin = Plugin.fromManifest(
          Manifest.path(WasmFiles.wasmNoFunctions),
          withWasi: true,
        );
        final output = plugin.callWithString(
          'count_vowels',
          'a' * (65536 * 2),
        );
        expect(output.isOk(), isTrue);
        final {'count': count} = output.unwrap().toJsonMap();
        print('#3 count = $count');
      }
    });

    tearDown(() {
      extism.logDrain(
        (String output, int len) => print('[log] len = $len, output = $output'),
      );
    });
  });
}
