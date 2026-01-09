// ========== IMPORTS ========== //
// Flutter
import 'package:flutter/material.dart';

// ========== NOTIFICATION PAGE ========== //
class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 30,
            fontFamily: 'Lobster',
          )
        ),
      ),
      body: const Center(
        child: Text('Notification Page'),
      ),
    );
  }
}