import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:Spark/services/messagerie_service.dart';
import 'package:Spark/screens/match-messagerie/message_detail_screen.dart';
import 'package:Spark/widgets/lazy_loading_page.dart';

class MessageriePage extends StatefulWidget with LazyLoadingPage {
  const MessageriePage({Key? key}) : super(key: key);

  @override
  _MessageriePageState createState() => _MessageriePageState();

  @override
  Future<void> loadData() async {
    await _MessageriePageState()._fetchMessageries();
  }
}

class _MessageriePageState extends State<MessageriePage> {
  final MessagerieServiceAPI _messagerieServiceAPI = MessagerieServiceAPI();
  List<Map<String, dynamic>> messageries = [];

  @override
  void initState() {
    super.initState();
    _fetchMessageries();
  }

  Future<void> _fetchMessageries() async {
    try {
      final response = await _messagerieServiceAPI.getMessagerieByUserID();
      if (response.statusCode == 200) {
        setState(() {
          messageries = (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch messageries')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch messageries: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Matches',
          style: TextStyle(
            fontSize: 30,
            fontFamily: 'Lobster',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality if needed
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: messageries.length,
        itemBuilder: (context, index) {
          final messagerie = messageries[index];
          return Card(
            margin: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    messagerie['profilePic'] ?? 'https://source.unsplash.com/50x50/',
                  ),
                ),
                title: Text(messagerie['name'] ?? 'Unknown'),
                subtitle: Text(messagerie['description'] ?? 'No description'),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MessageDetailPage(messagerieId: messagerie['messagerie_id']),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}