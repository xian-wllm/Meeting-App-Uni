import 'package:flutter/material.dart';

class BlockedUsersPage extends StatelessWidget {
  const BlockedUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Users'),
      ),
      body: ListView.builder(
        itemCount: 10, 
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Calendrier & Travail terminé ${index + 1}'),
            // Ajoutez ici d'autres informations sur l'utilisateur bloqué si nécessaire
          );
        },
      ),
    );
  }
}