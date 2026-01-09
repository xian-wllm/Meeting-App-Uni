import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Spark/services/association_service.dart';

enum Tags {
  ALCOOL, ALLEMAND, ANGLAIS, ANIMAUX, ARCHEOLOGIE, ARTS_MARTIAUX, BATTELLE, BIOLOGIE, CHIMIE, CINEMA, CLIMAT, CMU, COMPETITION,
  DATCHA, DESSIN, DROIT, ECONOMIE, ESPAGNOL, ESPORT, ETUDES, ETUDIANTS, FESTIVALS, FOOTBALL, FRANCAIS, HANDICAPE, HISTOIRE,
  HOCKEY, INFORMATIQUE, ITALIEN, JEUX_VIDEO, LANGUES_ETRANGERES, LETTRES, MALE_ALPHA, MATHEMATIQUES, MEDECINE, MONTAGNE, 
  MUSIQUE, NATURE, NOURRITURE, PHILOSOPHIE, PHYSIQUE, PLAGE, PORTUGAIS, PSYCHOLOGIE, RESEAUX_SOCIAUX, SERIES, SOLITAIRE, 
  SORTIE, SPORTS, TATOUAGE, UNI_BASTION, UNI_DUFOUR, UNI_MAIL, UNI_SCIENCES, VOITURES, VOYAGE
}

// ========== CREATE ASSOCIATION ========== //
class CreateAssociationPage extends StatefulWidget {
  const CreateAssociationPage({super.key});
  final storage = const FlutterSecureStorage();

  @override
  _CreateAssociationPageState createState() => _CreateAssociationPageState();
}

class _CreateAssociationPageState extends State<CreateAssociationPage> {
  final AssociationServiceAPI apiService = AssociationServiceAPI();
  final storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _canJoin = true;
  final Set<Tags> _selectedTags = {};
  String? _imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'My Association',
          style: TextStyle(
            fontFamily: 'Lobster',
            fontSize: 30,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 75,
                      backgroundImage: _imageUrl != null
                          ? NetworkImage(_imageUrl!)
                          : const AssetImage('assets/profile_picture.png') as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickAndUploadAssociationImage,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LineIcons.camera),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name of the Association',
                  labelStyle: TextStyle(fontWeight: FontWeight.bold), // Text en gras
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description of the Association',
                  labelStyle: TextStyle(fontWeight: FontWeight.bold), // Text en gras
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Tags:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Wrap(
                spacing: 8.0,
                children: Tags.values.map((tag) {
                  return FilterChip(
                    label: Text(tag.toString().split('.').last),
                    selected: _selectedTags.contains(tag),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Can Join?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: _canJoin,
                    onChanged: (bool value) {
                      setState(() {
                        _canJoin = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => _createAssociation(context),
                  child: const Text(
                    'Create Association',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Lobster',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadAssociationImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      try {
        final imageUrl = await apiService.uploadImageAssociationToCloudinary(file);
        setState(() {
          _imageUrl = imageUrl;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    }
  }

  Future<void> _createAssociation(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final description = _descriptionController.text;
      final canJoin = _canJoin;
      final tags = _selectedTags.map((tag) => tag.toString().split('.').last).toList();

      try {
        final userId = await storage.read(key: 'userId');
        final data = {
          'asso_id': null,
          'name': name,
          'description': description,
          'image': _imageUrl ?? 'ttps://source.unsplash.com/75x75',
          'canJoin': canJoin,
          'tags': tags,
          'moderators': [userId]
        };
        print(data);
        final response = await apiService.createAssociation(data);

        if (response.statusCode == 204) { // HTTP 201 for successful creation
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Association created successfully')),
          );
          Navigator.pop(context);
        } else if (response.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unauthorized: Please check your credentials')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create association: ${response.body}, ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create association: $e')),
        );
      }
    }
  }
}
