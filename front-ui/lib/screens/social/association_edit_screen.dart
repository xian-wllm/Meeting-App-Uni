// ========== IMPORTS ========== //
// Flutter
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Services
import 'package:Spark/services/association_service.dart';

// ========== ENUM TAGS ========== //
enum Tags {
  ALCOOL, ALLEMAND, ANGLAIS, ANIMAUX, ARCHEOLOGIE, ARTS_MARTIAUX, BATTELLE, BIOLOGIE, CHIMIE, CINEMA, CLIMAT, CMU, COMPETITION,
  DATCHA, DESSIN, DROIT, ECONOMIE, ESPAGNOL, ESPORT, ETUDES, ETUDIANTS, FESTIVALS, FOOTBALL, FRANCAIS, HANDICAPE, HISTOIRE,
  HOCKEY, INFORMATIQUE, ITALIEN, JEUX_VIDEO, LANGUES_ETRANGERES, LETTRES, MALE_ALPHA, MATHEMATIQUES, MEDECINE, MONTAGNE, 
  MUSIQUE, NATURE, NOURRITURE, PHILOSOPHIE, PHYSIQUE, PLAGE, PORTUGAIS, PSYCHOLOGIE, RESEAUX_SOCIAUX, SERIES, SOLITAIRE, 
  SORTIE, SPORTS, TATOUAGE, UNI_BASTION, UNI_DUFOUR, UNI_MAIL, UNI_SCIENCES, VOITURES, VOYAGE
}

// ========== EDIT ASSOCIATION ========== //
class EditAssociationPage extends StatefulWidget {
  final Map<String, dynamic> assocData;
  const EditAssociationPage({super.key, required this.assocData});

  @override
  _EditAssociationState createState() => _EditAssociationState();
}

class _EditAssociationState extends State<EditAssociationPage> {
  final AssociationServiceAPI apiService = AssociationServiceAPI();
  final _formKey = GlobalKey<FormState>();

  // Association Parameter
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _canJoin = true;
  final Set<Tags> _selectedTags = {};
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.assocData['name']);
    _descriptionController = TextEditingController(text: widget.assocData['description']);
    _canJoin = widget.assocData['canJoin'];

    for (final tag in widget.assocData['tags']) {
      _selectedTags.add(Tags.values.firstWhere((e) => e.toString() == 'Tags.$tag'));
    }

    _imageUrl = widget.assocData['image'];
  }

  Future<void> _updateAssociation() async {
    if (_formKey.currentState!.validate()) {

      final response = await apiService.updateAssociation(widget.assocData);
      if (response.statusCode == 200) {
        Navigator.of(context).pop(true);
      } else {
         print('Failed to update association: ${response.statusCode} - ${response.body}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Edit Association',
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
                      backgroundImage: _imageUrl != null ? NetworkImage(_imageUrl!) : null,
                      child: _imageUrl == null ? const Icon(Icons.person, size: 75) : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: FloatingActionButton(
                        onPressed: () async {
                          final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            final imageUrl = await apiService.uploadImageAssociationToCloudinary(File(image.path));
                            setState(() {
                              _imageUrl = imageUrl;
                            });
                          }
                        },
                        child: const Icon(Icons.camera_alt),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
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
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CheckboxListTile(
                title: const Text('Can Join'),
                value: _canJoin,
                onChanged: (value) {
                  setState(() {
                    _canJoin = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              Wrap(
                children: Tags.values.map((tag) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: FilterChip(
                      label: Text(tag.toString().split('.').last),
                      selected: _selectedTags.contains(tag),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTags.add(tag);
                          } else {
                            _selectedTags.remove(tag);
                          }
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateAssociation,
                child: const Text('Update Association'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}