import 'package:test/test.dart';

import 'gc.dart';
import 'native_finalizer_test.dart';

Future<void> main() async {
  await runTestsInVmService(
    _core,
    selfFilePath: 'test/ffi/gc_test.dart',
  );
}

void _core(VmServiceUtil vmService) {
  test(
    'testMallocFree',
    () async {
      await testMallocFree(vmService.gc);
      // sleep(Duration(seconds: 1));
      remains();
    },
    timeout: Timeout(Duration(minutes: 60)),
  );
}
