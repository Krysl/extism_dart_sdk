import 'package:path/path.dart' as path;
import 'package:stack_trace/stack_trace.dart' as stacktrace;

String currentDartFilePath({bool packageRelative = false}) {
  var caller = stacktrace.Frame.caller(2);
  return packageRelative ? caller.library : caller.uri.toFilePath();
}

String currentLogFilePath() => path.setExtension(
      currentDartFilePath(packageRelative: true),
      '.log',
    );
