import 'dart:developer';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'datamodel.dart';

Future<void> connectToDevice(BluetoothDevice device) async {
  try {
    log('Connecting to device: ${device.platformName}');
    await device.connect();
    log('Connected to device: ${device.platformName}');

    // Discover services
    List<BluetoothService> services = await device.discoverServices();
    log('Discovered services for ${device.platformName}: ${services.length}');

    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        // Look for the characteristic to read/write data
        if (characteristic.uuid.toString() == "12345678-1234-5678-1234-56789abcdef1") {
          // Read data from characteristic
          final data = await characteristic.read();
          final receivedData = String.fromCharCodes(data);
          log("Received Data: $receivedData");

          // Parse the "name:id" format
          try {
            final parsedData = BluetoothData.fromString(receivedData);
            log('Parsed BluetoothData: $parsedData');
          } catch (e) {
            log('Failed to parse data: $e');
          }
   
        }
      }
    }
  } catch (e) {
    log('Error connecting to device: $e');
  } finally {
    // Ensure proper cleanup
    await device.disconnect();
    log('Disconnected from device: ${device.platformName}');
  }
}