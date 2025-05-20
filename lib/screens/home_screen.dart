import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/bluetooth_service.dart';
import '../widgets/feature_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final authService = Provider.of<AuthService>(context);
    final bluetoothService = Provider.of<BluetoothServicee>(context);
    // final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Yoga Mat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: (){}
            //() => authService.signOut(),

          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome section
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
                            CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                              child: Icon(
                                Icons.person,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back,',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  // user?.displayName ?? 'Yogi',
                                  'Yogi',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Mat connection status
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: bluetoothService.isConnected
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                bluetoothService.isConnected
                                    ? Icons.bluetooth_connected
                                    : Icons.bluetooth_disabled,
                                color: bluetoothService.isConnected
                                    ? Colors.green
                                    : Colors.orange,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                bluetoothService.isConnected
                                    ? 'Connected to Mat'
                                    : 'Mat Not Connected',
                                style: TextStyle(
                                  color: bluetoothService.isConnected
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Mat overview
                Text(
                  'Your Smart Yoga Mat',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.asset(
                          'assets/images/yoga_mat.jpg',
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Smart Yoga Mat Pro',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'The Smart Yoga Mat Pro helps you perfect your poses with pressure sensors and real-time feedback. Connect via Bluetooth for a guided yoga experience.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/connection');
                              },
                              icon: const Icon(Icons.bluetooth),
                              label: Text(
                                bluetoothService.isConnected
                                    ? 'Manage Connection'
                                    : 'Connect to Mat',
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Features section
                Text(
                  'Features',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    FeatureCard(
                      icon: Icons.play_circle_outline,
                      title: 'Yoga Modes',
                      description: 'Start different yoga modes',
                      onTap: () {
                        Navigator.pushNamed(context, '/control_panel');
                      },
                    ),
                    FeatureCard(
                      icon: Icons.music_note,
                      title: 'Music & Sounds',
                      description: 'Relaxing sounds for your session',
                      onTap: () {
                        Navigator.pushNamed(context, '/music');
                      },
                    ),
                    FeatureCard(
                      icon: Icons.new_releases,
                      title: 'New Products',
                      description: 'Discover our latest offerings',
                      onTap: () {
                        Navigator.pushNamed(context, '/products');
                      },
                    ),
                    FeatureCard(
                      icon: Icons.system_update,
                      title: 'OTA Updates',
                      description: 'Keep your mat up to date',
                      onTap: () {
                        Navigator.pushNamed(context, '/ota_update');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
