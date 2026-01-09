import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:Spark/services/messagerie_service.dart';

class MessageDetailPage extends StatefulWidget {
  final int messagerieId;

  const MessageDetailPage({super.key, required this.messagerieId});

  @override
  _MessageDetailPageState createState() => _MessageDetailPageState();
}

class _MessageDetailPageState extends State<MessageDetailPage> {
  final MessagerieServiceAPI _messagerieServiceAPI = MessagerieServiceAPI();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      final response = await _messagerieServiceAPI.getMessageByMessagerieID(widget.messagerieId);
      if (response.statusCode == 200) {
        setState(() {
          messages = (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch messages')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch messages: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return ListTile(
            title: Text(message['sender']),
            subtitle: Text(message['text']),
          );
        },
      ),
    );
  }
}