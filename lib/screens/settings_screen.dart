import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool soundEnabled = true;
  bool darkMode = false;
  String reminderTime = '15 minutes before';
  String selectedTone = 'Tone 1';

  final List<String> tones = ['Tone 1', 'Tone 2', 'Tone 3', 'Tone 4'];
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _sectionTitle('Notifications'),
            _card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: _iconBox(Icons.notifications),
                    title: const Text('Enable Notifications'),
                    subtitle: const Text('Receive reminders on time'),
                    value: notificationsEnabled,
                    onChanged: (v) => setState(() => notificationsEnabled = v),
                  ),
                  const Divider(),
                  ListTile(
                    leading: _iconBox(Icons.volume_up),
                    title: const Text('Sound'),
                    subtitle: Text('Current: $selectedTone'),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ToneSelectionScreen(
                            tones: tones,
                            currentTone: selectedTone,
                            audioPlayer: audioPlayer,
                          ),
                        ),
                      );
                      if (result != null && result is String) {
                        setState(() => selectedTone = result);
                      }
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: _iconBox(Icons.alarm),
                    title: const Text('Reminder Time'),
                    subtitle: const Text('Select how early to be reminded'),
                    trailing: DropdownButton<String>(
                      value: reminderTime,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                          value: '5 minutes before',
                          child: Text('5 minutes before'),
                        ),
                        DropdownMenuItem(
                          value: '10 minutes before',
                          child: Text('10 minutes before'),
                        ),
                        DropdownMenuItem(
                          value: '15 minutes before',
                          child: Text('15 minutes before'),
                        ),
                        DropdownMenuItem(
                          value: '30 minutes before',
                          child: Text('30 minutes before'),
                        ),
                      ],
                      onChanged: (v) => setState(() => reminderTime = v!),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _sectionTitle('Appearance'),
            _card(
              child: SwitchListTile(
                secondary: _iconBox(Icons.dark_mode),
                title: const Text('Dark Mode'),
                subtitle: const Text('Enable dark appearance'),
                value: darkMode,
                onChanged: (v) => setState(() => darkMode = v),
              ),
            ),
            const SizedBox(height: 20),
            _sectionTitle('Security & Privacy'),
            _card(
              child: ListTile(
                leading: _iconBox(Icons.lock, iconColor: Colors.blue),
                title: const Text('Change Password'),
                trailing: const Text(
                  'Change',
                  style: TextStyle(color: Colors.blue),
                ),
                onTap: () {
                  // TODO: implement change password functionality
                },
              ),
            ),
            const SizedBox(height: 20),
            _sectionTitle('About App'),
            _card(
              child: ListTile(
                leading: _iconBox(Icons.info),
                title: const Text('About'),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: "Pill Box",
                    applicationVersion: "1.0.0",
                    applicationIcon: const Icon(
                      Icons.health_and_safety_outlined,
                      size: 40,
                      color: Color(0xFF4DB6D6),
                    ),
                    children: const [
                      Text(
                        "This app helps you organize your medicines and track adherence.",
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: child,
    );
  }

  Widget _iconBox(IconData icon, {Color iconColor = Colors.blue}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: iconColor),
    );
  }
}

/// ======================= Tone Selection Screen =======================
class ToneSelectionScreen extends StatelessWidget {
  final List<String> tones;
  final String currentTone;
  final AudioPlayer audioPlayer;

  const ToneSelectionScreen({
    super.key,
    required this.tones,
    required this.currentTone,
    required this.audioPlayer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Alarm Tone"), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tones.length,
        itemBuilder: (context, index) {
          final tone = tones[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(tone),
              trailing: currentTone == tone
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () async {
                // TODO: play the tone sound using audioPlayer
                // For example: await audioPlayer.play(AssetSource('tones/tone${index+1}.mp3'));
                Navigator.pop(context, tone);
              },
            ),
          );
        },
      ),
    );
  }
}
