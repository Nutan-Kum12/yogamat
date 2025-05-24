import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';

class ControlPanelScreen extends StatefulWidget {
  const ControlPanelScreen({Key? key}) : super(key: key);

  @override
  _ControlPanelScreenState createState() => _ControlPanelScreenState();
}

class _ControlPanelScreenState extends State<ControlPanelScreen> {
  bool _isWarmUpActive = false;
  bool _isRelaxationActive = false;
  String _statusMessage = 'Ready to start a session';

  Future<void> _toggleWarmUp() async {
    final bluetoothService = Provider.of<BluetoothServicee>(context, listen: false);
    
    if (!bluetoothService.isConnected) {
      _showNotConnectedDialog();
      return;
    }

    setState(() {
      _isWarmUpActive = !_isWarmUpActive;
      if (_isWarmUpActive) {
        _isRelaxationActive = false;
        _statusMessage = 'Warm-Up mode activated';
      } else {
        _statusMessage = 'Warm-Up mode deactivated';
      }
    });

    // Send command to mat
    await bluetoothService.sendCommand(_isWarmUpActive ? 'WARM_UP_ON' : 'WARM_UP_OFF');
  }

  Future<void> _toggleRelaxation() async {
    final bluetoothService = Provider.of<BluetoothServicee>(context, listen: false);
    
    if (!bluetoothService.isConnected) {
      _showNotConnectedDialog();
      return;
    }

    setState(() {
      _isRelaxationActive = !_isRelaxationActive;
      if (_isRelaxationActive) {
        _isWarmUpActive = false;
        _statusMessage = 'Relaxation mode activated';
      } else {
        _statusMessage = 'Relaxation mode deactivated';
      }
    });

    // Send command to mat
    await bluetoothService.sendCommand(_isRelaxationActive ? 'RELAXATION_ON' : 'RELAXATION_OFF');
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

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothServicee>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Panel'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status card
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
                              ? Icons.check_circle
                              : Icons.error,
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
                              _statusMessage,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Control modes
              Text(
                'Mat Functions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Warm-Up mode
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
                              color: _isWarmUpActive
                                  ? Colors.orange.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.whatshot,
                              color: _isWarmUpActive ? Colors.orange : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Warm-Up Mode',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Gentle heat to prepare your muscles for yoga',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _toggleWarmUp,
                          icon: Icon(_isWarmUpActive ? Icons.stop : Icons.play_arrow),
                          label: Text(_isWarmUpActive ? 'Stop Warm-Up' : 'Start Warm-Up'),
                          style: ElevatedButton.styleFrom(
                            // primary: _isWarmUpActive ? Colors.red : Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Relaxation mode
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
                              color: _isRelaxationActive
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.spa,
                              color: _isRelaxationActive ? Colors.blue : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Relaxation Mode',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Soothing vibrations to help you relax and meditate',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _toggleRelaxation,
                          icon: Icon(_isRelaxationActive ? Icons.stop : Icons.play_arrow),
                          label: Text(_isRelaxationActive ? 'Stop Relaxation' : 'Begin Relaxation'),
                          style: ElevatedButton.styleFrom(
                            // primary: _isRelaxationActive ? Colors.red : Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Tips
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
                        '• Use Warm-Up mode before starting your yoga session\n'
                        '• Relaxation mode is perfect for meditation and cool down\n'
                        '• Only one mode can be active at a time',
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
