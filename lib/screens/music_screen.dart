import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../services/database_service.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({Key? key}) : super(key: key);

  @override
  _MusicScreenState createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Map<String, dynamic>> _soundTracks = [];
  bool _isLoading = true;
  String? _currentlyPlayingId;
  double _volume = 0.5;

  @override
  void initState() {
    super.initState();
    _loadSoundTracks();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadSoundTracks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final databaseService = Provider.of<DatabaseService>(context, listen: false);
      final soundTracks = await databaseService.getSoundTracks();
      
      if (mounted) {
        setState(() {
          _soundTracks = soundTracks;
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
            content: Text('Error loading sound tracks: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _playSound(String id, String url) async {
    if (_currentlyPlayingId == id) {
      // Stop playing if the same track is tapped again
      await _audioPlayer.stop();
      setState(() {
        _currentlyPlayingId = null;
      });
    } else {
      // Play the new track
      try {
        await _audioPlayer.setUrl(url);
        await _audioPlayer.setVolume(_volume);
        await _audioPlayer.play();
        setState(() {
          _currentlyPlayingId = id;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing sound: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _setVolume(double value) {
    setState(() {
      _volume = value;
    });
    _audioPlayer.setVolume(value);
  }

  @override
  Widget build(BuildContext context) {
    // If no sounds are loaded from Firebase, use these default sounds
    if (_soundTracks.isEmpty && !_isLoading) {
      _soundTracks = [
        {
          'id': '1',
          'name': 'Ocean Waves',
          'description': 'Calming ocean waves for relaxation',
          'icon': 'water',
          'url': 'https://example.com/ocean_waves.mp3',
        },
        {
          'id': '2',
          'name': 'Breathing Exercise',
          'description': 'Guided breathing for meditation',
          'icon': 'air',
          'url': 'https://example.com/breathing.mp3',
        },
        {
          'id': '3',
          'name': 'Forest Ambience',
          'description': 'Peaceful forest sounds',
          'icon': 'forest',
          'url': 'https://example.com/forest.mp3',
        },
        {
          'id': '4',
          'name': 'Ambient Music',
          'description': 'Soft ambient music for yoga',
          'icon': 'music_note',
          'url': 'https://example.com/ambient.mp3',
        },
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Music & Sounds'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Relaxing Sounds',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a sound to play during your yoga session',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),

              // Volume control
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
                          const Icon(Icons.volume_up),
                          const SizedBox(width: 8),
                          Text(
                            'Volume',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.volume_mute, size: 20),
                          Expanded(
                            child: Slider(
                              value: _volume,
                              onChanged: _setVolume,
                              min: 0.0,
                              max: 1.0,
                            ),
                          ),
                          const Icon(Icons.volume_up, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Sound tracks
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _soundTracks.length,
                        itemBuilder: (context, index) {
                          final sound = _soundTracks[index];
                          final isPlaying = _currentlyPlayingId == sound['id'];
                          
                          IconData iconData;
                          switch (sound['icon']) {
                            case 'water':
                              iconData = Icons.water;
                              break;
                            case 'air':
                              iconData = Icons.air;
                              break;
                            case 'forest':
                              iconData = Icons.forest;
                              break;
                            case 'music_note':
                              iconData = Icons.music_note;
                              break;
                            default:
                              iconData = Icons.music_note;
                          }
                          
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              onTap: () => _playSound(sound['id'], sound['url']),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isPlaying
                                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                                            : Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        iconData,
                                        color: isPlaying
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sound['name'],
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            sound['description'],
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isPlaying ? Icons.stop_circle : Icons.play_circle,
                                        color: isPlaying
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey,
                                        size: 32,
                                      ),
                                      onPressed: () => _playSound(sound['id'], sound['url']),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
