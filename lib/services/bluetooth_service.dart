import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

class BluetoothServicee extends ChangeNotifier {
  fbp.BluetoothDevice? connectedDevice;
  bool isScanning = false;
  List< fbp.BluetoothDevice> discoveredDevices = [];

  bool get isConnected => connectedDevice != null;

  // Start scanning for devices
  Future<void> startScan() async {
    if (isScanning) return;

    discoveredDevices.clear();
    isScanning = true;
    notifyListeners();

    try {
      // Listen to scan results
      fbp.FlutterBluePlus.scanResults.listen((results) {
        for (fbp.ScanResult result in results) {
          if (!discoveredDevices.contains(result.device) &&
              result.device.name.isNotEmpty &&
              result.device.name.toLowerCase().contains('yoga')) {
            discoveredDevices.add(result.device);
            notifyListeners();
          }
        }
      });

      // Start scanning
      await fbp.FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    } finally {
      isScanning = false;
      notifyListeners();
    }
  }

  // Connect to a device
  Future<bool> connectToDevice(fbp.BluetoothDevice device) async {
    try {
      await device.connect();
      connectedDevice = device;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error connecting to device: $e');
      return false;
    }
  }

  // Disconnect from device
  Future<void> disconnect() async {
    if (connectedDevice != null) {
      try {
        await connectedDevice!.disconnect();
      } finally {
        connectedDevice = null;
        notifyListeners();
      }
    }
  }

  Future<bool> sendCommand(String command) async {
    if (connectedDevice == null) return false;

    try {
      List<fbp.BluetoothService> services = await connectedDevice!.discoverServices();
      for (fbp.BluetoothService service in services) {
        for (fbp.BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            await characteristic.write(command.codeUnits);
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      print('Error sending command: $e');
      return false;
    }
  }

  Future<bool> isBluetoothAvailable() async {
    try {
      return await fbp.FlutterBluePlus.isOn;
    } catch (e) {
      return false;
    }
  }
}
