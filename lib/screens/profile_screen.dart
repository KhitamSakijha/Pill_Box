import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;

  String userName = 'John Doe';
  String dob = "Jan 1, 1980";
  String bloodType = "O+";
  String weight = "75 kg";
  String height = "180 cm";

  String selectedAlarm = "Default";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userName');
    final alarm = prefs.getString('alarmSound');
    if (name != null && mounted) setState(() => userName = name);
    if (alarm != null && mounted) setState(() => selectedAlarm = alarm);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      setState(() => _image = File(pickedImage.path));
    }
  }

  /* Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }*/

  Future<void> _editInfo(
    String title,
    String currentValue,
    Function(String) onSave,
  ) async {
    final controller = TextEditingController(text: currentValue);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit $title"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Enter $title",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final newValue = controller.text.trim();
              if (newValue.isNotEmpty) {
                if (title == "Name") {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('userName', newValue);
                  setState(() => userName = newValue);
                } else {
                  onSave(newValue);
                }
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _profileCard(),
              const SizedBox(height: 20),
              _infoCard(),
              const SizedBox(height: 20),
              _settingsCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ================= Profile Card =================
  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? const Icon(Icons.person, size: 60, color: Colors.grey)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blue,
                      child: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _editInfo(
              "Name",
              userName,
              (v) => setState(() => userName = v),
            ),
            child: Text(
              userName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _smallInfo(Icons.cake, dob),
              const SizedBox(width: 20),
              _smallInfo(Icons.bloodtype, bloodType),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallInfo(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 6),
        Text(value, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  // ================= Info Card =================
  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          _InfoTile(
            Icons.monitor_weight,
            'Weight',
            weight,
            onTap: () =>
                _editInfo("Weight", weight, (v) => setState(() => weight = v)),
          ),
          const Divider(),
          _InfoTile(
            Icons.height,
            'Height',
            height,
            onTap: () =>
                _editInfo("Height", height, (v) => setState(() => height = v)),
          ),
        ],
      ),
    );
  }

  // ================= Settings Card =================
  Widget _settingsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.blue),
            title: const Text('Settings'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.orange),
            title: const Text('Alarm Sound'),
            trailing: Text(
              selectedAlarm,
              style: const TextStyle(color: Colors.grey),
            ),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AlarmSoundScreen(selectedAlarm: selectedAlarm),
                ),
              );
              if (result != null) {
                setState(() => selectedAlarm = result);
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log Out', style: TextStyle(color: Colors.red)),
            //عدلت على زر الخروج بحيث يخرج من قاعدة البيانات
            onTap: () async {
              await FirebaseAuth.instance.signOut();

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false, // هذا يعني إزالة كل الصفحات السابقة
              );
            },
          ),
        ],
      ),
    );
  }
}

// ================= InfoTile Widget =================
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _InfoTile(this.icon, this.title, this.value, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      horizontalTitleGap: 0,
    );
  }
}

// ================= Alarm Sound Screen =================
class AlarmSoundScreen extends StatelessWidget {
  final String selectedAlarm;
  const AlarmSoundScreen({super.key, required this.selectedAlarm});

  @override
  Widget build(BuildContext context) {
    final alarms = ["Default", "Beep", "Chime", "Melody", "Alert"];
    return Scaffold(
      appBar: AppBar(title: const Text("Select Alarm Sound")),
      body: ListView.separated(
        itemCount: alarms.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final alarm = alarms[index];
          return ListTile(
            title: Text(alarm),
            trailing: alarm == selectedAlarm
                ? const Icon(Icons.check, color: Colors.blue)
                : null,
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('alarmSound', alarm);
              Navigator.pop(context, alarm);
            },
          );
        },
      ),
    );
  }
}
