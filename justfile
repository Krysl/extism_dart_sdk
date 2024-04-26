alias f:=ffigen
alias j:=json_gen
alias c:=coverage

fix:
  dart fix --apply .
ffigen:
  dart run ffigen .

json_gen:
  dart run build_runner build

coverage:
  dart pub global run coverage:test_with_coverage

sdk:="D:/flutter/dart-sdk/sdk/"
pwd:=`pwd`
t:
  #!/bin/sh
  cd {{sdk}}
  set DART_CONFIGURATION=DebugX64 & \
  set DART_SUPPRESS_WER=1 & \
  out/DebugX64/dart.exe \
    -Dtest_runner.configuration=vm-ffi-unit-test \
    --ignore-unrecognized-flags \
    --packages=.dart_tool/package_config.json \
    {{pwd}}/test/ffi/native_finalizer_test.dart
t2:
  #!/bin/sh
  cd {{sdk}}
  set DART_CONFIGURATION=DebugX64 & echo DART_CONFIGURATION = %DART_CONFIGURATION%
  export DART_CONFIGURATION=DebugX64 & echo DART_CONFIGURATION = %DART_CONFIGURATION%

  set DART_CONFIGURATION=DebugX64 & \
  set DART_SUPPRESS_WER=1 & \
  out/DebugX64/dart.exe \
    -Dtest_runner.configuration=vm-ffi-unit-test \
    --ignore-unrecognized-flags \
    --packages=.dart_tool/package_config.json \
    native_finalizer_test.dart

to: 
  #!/bin/sh
  cd {{sdk}}
  set DART_CONFIGURATION=DebugX64 & \
  set DART_SUPPRESS_WER=1 & \
  out/DebugX64/dart.exe \
    -Dtest_runner.configuration=vm-ffi-unit-test \
    --ignore-unrecognized-flags \
    --packages=.dart_tool/package_config.json \
    tests/ffi/vmspecific_native_finalizer_test.dart