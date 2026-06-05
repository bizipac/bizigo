import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rd_sample/rd_sample.dart';

void main() {
  const MethodChannel channel = MethodChannel('rd_sample');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await RdSample.platformVersion, '42');
  });
}
