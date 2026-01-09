import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Spark/provider/event_provider.dart';
import 'package:Spark/screens/social/event_create_screen.dart';
import 'package:Spark/services/association_service.dart';
import 'package:Spark/services/profile_service.dart';
import 'package:Spark/services/event_service.dart';
import 'package:Spark/widgets/navigation_bottom_widget.dart';
import 'package:Spark/screens/social/association_edit_screen.dart';

class AssociationDetailPage extends StatefulWidget {
  final int associationId;
  const AssociationDetailPage({Key? key, required this.associationId}) : super(key: key);

  @override
  _AssociationDetailPageState createState() => _AssociationDetailPageState();
}

class _AssociationDetailPageState extends State<AssociationDetailPage> {
  final AssociationServiceAPI _associationService = AssociationServiceAPI();
  final ProfileServiceAPI _profileService = ProfileServiceAPI();
  final EventServiceAPI _eventService = EventServiceAPI();

  Map<String, dynamic>? association;
  List<String>? moderators;
  List<Map<String, dynamic>>? events;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _fetchAssociationDetails();
      _fetchAssociationEvents();
    });
  }

  Future<void> _fetchAssociationDetails() async {
    try {
      final response = await _associationService.getAssociationByID(widget.associationId);
      if (response.statusCode == 200) {
        final associationData = jsonDecode(response.body) as Map<String, dynamic>;
        final List<String> fetchedModerators = [];
        for (final id in associationData['moderators']) {
          final response = await _profileService.getUserByID(id);
          if (response.statusCode == 200) {
            fetchedModerators.add(jsonDecode(response.body)['fullname']);
          }
        }
        setState(() {
          association = associationData;
          moderators = fetchedModerators;
        });
      } else {
        print('Failed to fetch association details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching association details: $e');
    }
  }

  Future<void> _fetchAssociationEvents() async {
    try {
      final response = await _eventService.getEventsByAssociationID(widget.associationId);
      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> eventsData = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        setState(() {
          events = eventsData;
        });
        final eventProvider = Provider.of<EventProvider>(context, listen: false);
        eventProvider.setEvents(eventsData);
      } else {
        print('Failed to fetch events: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  Future<void> _deleteAssociation() async {
    try {
      final response = await _associationService.deleteAssociation(widget.associationId);
      if (response.statusCode == 204) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const NavigationBottom()),
          (Route<dynamic> route) => false,
        );
      } else {
        print('Failed to delete association: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting association: $e');
    }
  }

  Future<void> _deleteEvent(int eventId) async {
    try {
      final response = await _eventService.deleteEvent(eventId);
      if (response.statusCode == 204) {
        setState(() {
          events!.removeWhere((event) => event['id'] == eventId);
        });
      } else {
        print('Failed to delete event: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting event: $e');
    }
  }

  void _showEventDetails(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(event['nom_event'] ?? 'No Name'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const SizedBox(height: 16),
                Text(
                  event['description'] ?? 'No Description',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Date: ${event['date']}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _createNewEvent() async {
    final newEvent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEventPage(associationId: widget.associationId),
      ),
    );

    if (newEvent != null) {
      setState(() {
        events?.add(newEvent);
        final eventProvider = Provider.of<EventProvider>(context, listen: false);
        eventProvider.addEvent(newEvent);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          association?['name'] ?? 'Association Detail',
          style: const TextStyle(
            fontSize: 28,
            fontFamily: 'Lobster',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: association != null
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditAssociationPage(assocData: association!),
                      ),
                    );
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Delete Association"),
                    content: const Text("Are you sure you want to delete this association?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _deleteAssociation();
                        },
                        child: const Text("Delete"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: association != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (association!['image'] != null) Image.network(association!['image']),
                    const SizedBox(height: 16.0),
                    Text(
                      association!['name'] ?? 'No Name',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    Text(association!['description'] ?? 'No Description'),
                    const SizedBox(height: 16.0),
                    if (association!['moderators'] != null)
                      Text(
                        'Moderators: ${moderators!.join(', ')}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    const SizedBox(height: 16.0),
                    if (association!['tags'] != null)
                      const Text(
                        'Tags:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: association!['tags'].map<Widget>((tag) {
                        return Chip(
                          label: Text(tag),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Events',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    events != null
                        ? SizedBox(
                            height: 300, // Set a fixed height for the ListView
                            child: ListView.builder(
                              itemCount: events!.length,
                              itemBuilder: (context, index) {
                                final event = events![index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                  elevation: 3,
                                  child: ListTile(
                                    leading: const Icon(Icons.event), // Removed the image condition as events don't have images
                                    title: Text(
                                      event['nom_event'] ?? 'No Name',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      event['description'] ?? 'No Description',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text("Delete Event"),
                                                  content: const Text("Are you sure you want to delete this event?"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text("Cancel"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        Navigator.pop(context);
                                                        await _deleteEvent(event['event_id']);
                                                      },
                                                      child: const Text("Delete"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        const Icon(Icons.arrow_forward_ios),
                                      ],
                                    ),
                                    onTap: () {
                                      _showEventDetails(event);
                                    },
                                  ),
                                );
                              },
                            ),
                          )
                        : const Center(child: CircularProgressIndicator()), // Modified this line to center the CircularProgressIndicator
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        if (association!['canJoin'] == true)
                          ElevatedButton(
                            onPressed: () {
                              // Implement join functionality
                            },
                            child: const Text('Join Association'),
                          ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _createNewEvent, // Updated to call _createNewEvent
                          child: const Text('Add Event'),
                        ),
                      ],
                    ),
                  ],
                )
              : const Center(child: CircularProgressIndicator()), // Modified this line to center the CircularProgressIndicator
        ),
      ),
    );
  }
}