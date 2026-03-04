import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // مثال على إشعارات ثابتة
    final List<Map<String, String>> notifications = [
      {'title': 'Time to take Metformin', 'subtitle': '9:00 AM – 500 mg'},
      {'title': 'Check your blood pressure', 'subtitle': '10:00 AM'},
      {
        'title': 'Daily Motivation',
        'subtitle': '“A small step today leads to better health tomorrow.”',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.notifications, color: Colors.blue),
              title: Text(notif['title']!),
              subtitle: Text(notif['subtitle']!),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // هنا ممكن تضيف أي وظيفة عند الضغط على الإشعار
              },
            ),
          );
        },
      ),
    );
  }
}
