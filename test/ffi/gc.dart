import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:logger/logger.dart';
import 'package:test/test.dart';
import 'package:vm_service/vm_service.dart' hide Isolate;
import 'package:vm_service/vm_service.dart' as vm_service;
import 'package:vm_service/vm_service_io.dart';

const _kTag = 'vm_services';
void log(
  Level level,
  dynamic message, {
  DateTime? time,
  Object? error,
  StackTrace? stackTrace,
}) {
  print(message);
}

// ignore: avoid_classes_with_only_static_members
class Log {
  /// Log a message at level [Level.debug].
  static void d(
    String tag,
    String message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      log(Level.debug, '[$tag] $message',
          time: time, error: error, stackTrace: stackTrace);

  /// Log a message at level [Level.warning].
  static void w(
    String tag,
    String message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(Level.warning, '[$tag] $message',
        time: time, error: error, stackTrace: stackTrace);
  }

  /// Log a message at level [Level.error].
  static void e(
    String tag,
    String message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(Level.error, '[$tag] $message',
        time: time, error: error, stackTrace: stackTrace);
  }
}

FutureOr<void> runTestsInVmService(
  FutureOr<void> Function(VmServiceUtil) body, {
  required String selfFilePath,
}) async {
  print('''
[$_kTag] runInVmService
            selfFilePath = $selfFilePath
    Platform.script.path = ${Platform.script.path}
''');

  if (Platform.script.path.endsWith(selfFilePath)) {
    // in subprocess
    final vmService = await VmServiceUtil.create();
    // tearDownAll(vmService.dispose);
    await body(vmService);

    tearDownAll(() {
      print('vmService.dispose();');
      closeSubprocess(vmService);
    });
  } else {
    test('run all tests in subprocess', () async {
      await executeProcess('dart', [
        'run',
        '--enable-vm-service',
        // '--pause-isolates-on-start',
        selfFilePath,
      ]);
    });
  }
}

Future<void> closeSubprocess(VmServiceUtil vmService) async {
  final isolateId = Service.getIsolateId(Isolate.current)!;
  sleep(Duration(milliseconds: 2000));
  await vmService.vmService.kill(isolateId);
  await vmService.dispose();
}

class VmServiceUtil {
  static const _kTag = 'VmServiceUtil';

  final VmService vmService;

  VmServiceUtil._(this.vmService);

  static Future<VmServiceUtil> create() async {
    final serverUri = (await Service.getInfo()).serverUri;
    if (serverUri == null) {
      throw Exception('Cannot find serverUri for VmService. '
          'Ensure you run like `dart run --enable-vm-service path/to/your/file.dart`');
    }

    final vmService =
        await vmServiceConnectUri(_toWebSocket(serverUri), log: _log());
    return VmServiceUtil._(vmService);
  }

  Future<void> dispose() async {
    await vmService.dispose();
  }

  Future<void> gc() async {
    final isolateId = Service.getIsolateId(Isolate.current)!;
    final profile = await vmService.getAllocationProfile(isolateId, gc: true);
    Log.d(_kTag, 'gc triggered (heapUsage=${profile.memoryUsage?.heapUsage})');
  }
}

String _toWebSocket(Uri uri) {
  final pathSegments = [...uri.pathSegments.where((s) => s.isNotEmpty), 'ws'];
  return uri.replace(scheme: 'ws', pathSegments: pathSegments).toString();
}

class _log extends vm_service.Log {
  static const _kTag = 'vm_services';

  @override
  void warning(String message) => Log.w(_kTag, message);

  @override
  void severe(String message) => Log.e(_kTag, message);
}

Future<void> executeProcess(String executable, List<String> arguments) async {
  Log.d(_kTag, 'executeProcess start `$executable ${arguments.join(" ")}`');

  final process = await Process.start(executable, arguments);

  process.stdout.listen(
    (e) => Log.d(
      _kTag,
      String.fromCharCodes(e),
    ),
  );
  process.stderr.listen(
    (e) => Log.d(
      _kTag,
      '[STDERR] ${String.fromCharCodes(e)}',
    ),
  );

//  stdout.addStream(process.stdout);
//  stderr.addStream(process.stderr);

  final exitCode = await process.exitCode;
  Log.d(_kTag, 'executeProcess end exitCode=$exitCode');
  if (exitCode != 0 && exitCode != 255) {
    throw Exception('Process execution failed (exitCode=$exitCode)');
  }
}
