import 'dart:io';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final FlutterDriver driver = await FlutterDriver.connect();
  await integrationDriver(
    driver: driver,
    onScreenshot: (String screenshotName, List<int> imageBytes, [Map<String, dynamic>? args]) async {
      final File image = File('screenshots/$screenshotName.png');
      await image.create(recursive: true);
      await image.writeAsBytes(imageBytes);
      print('Screenshot saved successfully: screenshots/$screenshotName.png');
      return true;
    },
  );
}
