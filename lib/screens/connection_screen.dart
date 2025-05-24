import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;


class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({Key? key}) : super(key: key);

  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  bool _isScanning = false;
  

  @override
  void initState() {
    super.initState();
    _checkBluetoothStatus();
  }

  Future<void> _checkBluetoothStatus() async {
    final bluetoothService = Provider.of<BluetoothServicee>(context, listen: false);
    bool isAvailable = await bluetoothService.isBluetoothAvailable();
    
    if (!isAvailable && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bluetooth is not available or turned off'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
    });

    try {
      await Provider.of<BluetoothServicee>(context, listen: false).startScan();
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _connectToDevice(fbp.BluetoothDevice device) async {
    final bluetoothService = Provider.of<fbp.BluetoothService>(context, listen: false);
    
    // Show connecting dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Connecting to device...'),
          ],
        ),
      ),
    );

    // bool success = await bluetoothService.connectToDevice(device);
    
    // Close dialog
  //   if (mounted) {
  //     Navigator.pop(context);
      
  //     if (success) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Successfully connected to mat'),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Failed to connect to mat'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  }

  Future<void> _disconnect() async {
    final bluetoothService = Provider.of<BluetoothServicee>(context, listen: false);
    await bluetoothService.disconnect();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Disconnected from mat'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothServicee>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to Mat'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connection status card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: bluetoothService.isConnected
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          bluetoothService.isConnected
                              ? Icons.bluetooth_connected
                              : Icons.bluetooth_disabled,
                          color: bluetoothService.isConnected
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bluetoothService.isConnected
                                  ? 'Connected'
                                  : 'Not Connected',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: bluetoothService.isConnected
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bluetoothService.isConnected
                                  ? 'Your mat is connected and ready to use'
                                  : 'Connect to your Smart Yoga Mat to get started',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Connected device or scan button
              if (bluetoothService.isConnected)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connected Device',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.devices, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bluetoothService.connectedDevice?.name ?? 'Smart Yoga Mat',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    bluetoothService.connectedDevice?.id.toString() ?? '',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _disconnect,
                              style: ElevatedButton.styleFrom(
                                // primary: Colors.red,
                              ),
                              child: const Text('Disconnect'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              else
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _isScanning ? null : _startScan,
                    icon: _isScanning
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.bluetooth_searching),
                    label: Text(_isScanning ? 'Scanning...' : 'Scan for Devices'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Available devices
              if (!bluetoothService.isConnected) ...[
                Text(
                  'Available Devices',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: bluetoothService.discoveredDevices.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bluetooth_disabled,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _isScanning
                                    ? 'Searching for devices...'
                                    : 'No devices found',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (!_isScanning)
                                Text(
                                  'Make sure your Smart Yoga Mat is turned on and nearby',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                  ),
                                ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: bluetoothService.discoveredDevices.length,
                          itemBuilder: (context, index) {
                            final device = bluetoothService.discoveredDevices[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.bluetooth),
                                title: Text(device.name),
                                subtitle: Text(device.id.toString()),
                                trailing: ElevatedButton(
                                  onPressed: () => _connectToDevice(device),
                                  child: const Text('Connect'),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

