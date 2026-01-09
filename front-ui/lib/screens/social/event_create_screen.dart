import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Spark/services/event_service.dart';

enum Tags {
  ALCOOL, ALLEMAND, ANGLAIS, ANIMAUX, ARCHEOLOGIE, ARTS_MARTIAUX, BATTELLE, BIOLOGIE, CHIMIE, CINEMA, CLIMAT, CMU, COMPETITION,
  DATCHA, DESSIN, DROIT, ECONOMIE, ESPAGNOL, ESPORT, ETUDES, ETUDIANTS, FESTIVALS, FOOTBALL, FRANCAIS, HANDICAPE, HISTOIRE,
  HOCKEY, INFORMATIQUE, ITALIEN, JEUX_VIDEO, LANGUES_ETRANGERES, LETTRES, MALE_ALPHA, MATHEMATIQUES, MEDECINE, MONTAGNE, 
  MUSIQUE, NATURE, NOURRITURE, PHILOSOPHIE, PHYSIQUE, PLAGE, PORTUGAIS, PSYCHOLOGIE, RESEAUX_SOCIAUX, SERIES, SOLITAIRE, 
  SORTIE, SPORTS, TATOUAGE, UNI_BASTION, UNI_DUFOUR, UNI_MAIL, UNI_SCIENCES, VOITURES, VOYAGE
}

class CreateEventPage extends StatefulWidget {
  final int associationId;
  const CreateEventPage({super.key, required this.associationId});
  final storage = const FlutterSecureStorage();

  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final EventServiceAPI _eventServiceAPI = EventServiceAPI();
  final storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isPrivate = false;
  final Set<Tags> _selectedTags = {};
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Create Event',
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
              const SizedBox(height: 30),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name of the Event',
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
                  labelText: 'Description of the Event',
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
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 8.0),
                  TextButton(
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(DateTime.now().year + 5),
                      );
                      if (pickedDate != null) {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            _selectedDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
                          });
                        }
                      }
                    },
                    child: Text(
                      _selectedDate != null ? 'Selected Date: ${_selectedDate!.toString().substring(0, 16)}' : 'Select Date and Time',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'is Private?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: _isPrivate,
                    onChanged: (bool value) {
                      setState(() {
                        _isPrivate = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => _createEvent(context),
                  child: const Text(
                    'Create Event',
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

  Future<void> _createEvent(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final date = _selectedDate?.toIso8601String();
      final description = _descriptionController.text;
      final isPrivate = _isPrivate;
      final tags = _selectedTags.map((tag) => tag.toString().split('.').last).toList();

      try {
        final userId = await storage.read(key: 'userId');
        final data = {
          'event_id': null,
          'nom_event': name,
          'date': date,
          'description': description,
          'tags': tags,
          'organisateurs': [widget.associationId],
          'participants': [userId],
          'isPrivate': isPrivate,
        };
        print(data);
        final response = await _eventServiceAPI.createEvent(data);

        if (response.statusCode == 204) { // HTTP 204 for successful creation
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event created successfully')),
          );
          Navigator.pop(context, data); // Return the created event data
        } else if (response.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unauthorized: Please check your credentials')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create event: ${response.body}, ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create event: $e')),
        );
      }
    }
  }
}