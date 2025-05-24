import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
import '../services/database_service.dart';
import 'dart:async';

class OtaUpdateScreen extends StatefulWidget {
  const OtaUpdateScreen({Key? key}) : super(key: key);

  @override
  _OtaUpdateScreenState createState() => _OtaUpdateScreenState();
}

class _OtaUpdateScreenState extends State<OtaUpdateScreen> {
  bool _isLoading = true;
  bool _isUpdating = false;
  Map<String, dynamic>? _firmwareInfo;
  String _currentVersion = '1.0.0';
  bool _updateAvailable = false;
  double _updateProgress = 0.0;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _loadFirmwareInfo();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadFirmwareInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final databaseService = Provider.of<DatabaseService>(context, listen: false);
      final firmwareInfo = await databaseService.getFirmwareInfo();
      
      if (mounted) {
        setState(() {
          _firmwareInfo = firmwareInfo;
          
          if (firmwareInfo != null) {
            _currentVersion = '1.0.0';
            final latestVersion = firmwareInfo['version'] ?? '1.1.0';
            
            _updateAvailable = latestVersion.compareTo(_currentVersion) > 0;
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading firmware info: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _startUpdate() async {
    final bluetoothService = Provider.of<BluetoothServicee>(context, listen: false);
    
    if (!bluetoothService.isConnected) {
      _showNotConnectedDialog();
      return;
    }

    setState(() {
      _isUpdating = true;
      _updateProgress = 0.0;
    });

    _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _updateProgress += 0.05;
        if (_updateProgress >= 1.0) {
          _updateProgress = 1.0;
          _isUpdating = false;
          timer.cancel();
          
          if (_firmwareInfo != null) {
            _currentVersion = _firmwareInfo!['version'] ?? '1.1.0';
            _updateAvailable = false;
          }
          
          _showUpdateSuccessDialog();
        }
      });
    });

    await bluetoothService.sendCommand('START_OTA_UPDATE');
  }

  void _showNotConnectedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Not Connected'),
        content: const Text('Please connect to your Smart Yoga Mat first.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/connection');
            },
            child: const Text('Connect Now'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showUpdateSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Successful'),
        content: Text('Your Smart Yoga Mat has been updated to version $_currentVersion.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothServicee>(context);

    if (_firmwareInfo == null && !_isLoading) {
      _firmwareInfo = {
        'version': '1.1.0',
        'releaseDate': '2023-05-15',
        'description': 'This update improves pressure sensitivity and adds new yoga pose detection.',
        'size': '2.4 MB',
      };
      _updateAvailable = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('OTA Updates'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Connection status
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
                                        ? 'Mat Connected'
                                        : 'Mat Not Connected',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    bluetoothService.isConnected
                                        ? 'Ready for updates'
                                        : 'Connect to update your mat',
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

                    
                    Text(
                      'Current Firmware',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
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
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.memory,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Version $_currentVersion',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _updateAvailable
                                            ? 'Update available'
                                            : 'Your mat is up to date',
                                        style: TextStyle(
                                          color: _updateAvailable
                                              ? Colors.orange
                                              : Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (_updateAvailable) ...[
                      Text(
                        'Available Update',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
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
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.system_update,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Version ${_firmwareInfo!['version']}',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Released: ${_firmwareInfo!['releaseDate']}',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Size: ${_firmwareInfo!['size']}',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'What\'s New:',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _firmwareInfo!['description'],
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),
                              if (_isUpdating) ...[
                                const Text('Updating...'),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: _updateProgress,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${(_updateProgress * 100).toInt()}%',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ] else ...[
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: bluetoothService.isConnected
                                        ? _startUpdate
                                        : null,
                                    icon: const Icon(Icons.system_update),
                                    label: const Text('Update Now'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    Text(
                      'Update History',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          ListTile(
                            leading: const Icon(Icons.history),
                            title: const Text('Version 1.0.0'),
                            subtitle: const Text('Initial Release - 2023-01-15'),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.history),
                            title: const Text('Version 0.9.0'),
                            subtitle: const Text('Beta Release - 2022-12-01'),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Card(
                      elevation: 1,
                      color: Colors.blue.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.lightbulb, color: Colors.amber),
                                const SizedBox(width: 8),
                                Text(
                                  'Tips',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '• Make sure your mat is charged before updating\n'
                              '• Keep your phone close to the mat during updates\n'
                              '• Do not use the mat while updating',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
