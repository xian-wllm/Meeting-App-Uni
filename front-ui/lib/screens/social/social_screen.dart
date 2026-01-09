// ========== SOCIAL PAGE ========== //
// Flutter
import 'dart:convert';
import 'package:flutter/material.dart';

// Screens
import 'package:Spark/screens/social/association_detail_screen.dart';
import 'package:Spark/screens/social/association_create_screen.dart';

// Services
import 'package:Spark/services/association_service.dart';

// Widgets
import 'package:Spark/widgets/custom_search_widget.dart';
import 'package:Spark/widgets/lazy_loading_page.dart';

// ========== SOCIAL PAGE ========== //
class SocialPage extends StatefulWidget with LazyLoadingPage {
  const SocialPage({super.key});

  @override
  _SocialPageState createState() => _SocialPageState();

  @override
  Future<void> loadData() async {
    // Custom method to load data for this page
    await _SocialPageState()._fetchAssociations();
  }
}

class _SocialPageState extends State<SocialPage> {
  final AssociationServiceAPI _associationService = AssociationServiceAPI();
  List<Map<String, dynamic>> associations = [];

  @override
  void initState() {
    super.initState();
    _fetchAssociations();
  }

  // Fetch associations
  Future<void> _fetchAssociations() async {
    try {
      final response = await _associationService.getListAssociations();
      if (response.statusCode == 200) {
        setState(() {
          associations = (jsonDecode(response.body)).cast<Map<String, dynamic>>();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch associations')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch associations: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Social',
          style: TextStyle(
            fontSize: 30,
            fontFamily: 'Lobster',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: CustomSearchDelegate(associations: associations));
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _fetchAssociations();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateAssociationPage()),
              ).then((_) => _fetchAssociations()); // Refresh the list after returning from the create page
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: associations.length,
        itemBuilder: (context, index) {
          final association = associations[index];
          print(association);
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
                  backgroundImage: NetworkImage(association['image'] ?? 'https://source.unsplash.com/50x50/'),
                ),
                title: Text(association['name']),
                subtitle: Text(association['description']),
                trailing: association['canJoin']
                    ? ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AssociationDetailPage(associationId: association['asso_id']),
                            ),
                          );
                        },
                        child: const Text('About'),
                      )
                    : null,
                onTap: () {
                  // Implement navigation to association details
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
