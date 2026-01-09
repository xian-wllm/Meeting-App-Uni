import 'package:Spark/provider/event_provider.dart';
import 'package:Spark/screens/social/association_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:Spark/widgets/lazy_loading_page.dart';

class CalendarPage extends StatefulWidget with LazyLoadingPage {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();

  @override
  Future<void> loadData() async {
    // Custom method to load data for this page
    await _CalendarPageState()._loadInitialEvents();
  }
}

class _CalendarPageState extends State<CalendarPage> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      eventProvider.fetchAllEvents().then((_) {
        _groupEventsByDate(eventProvider.events);
      });
    });
  }

  Future<void> _loadInitialEvents() async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    await eventProvider.fetchAllEvents();
    _groupEventsByDate(eventProvider.events);
  }

  void _groupEventsByDate(List<Map<String, dynamic>> allEvents) {
    setState(() {
      _events.clear();
      for (var event in allEvents) {
        DateTime eventDate = DateTime.parse(event['date']);
        final dateKey = DateTime(eventDate.year, eventDate.month, eventDate.day);
        if (_events[dateKey] == null) {
          _events[dateKey] = [];
        }
        _events[dateKey]!.add(event);
      }
    });
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return _events[dateKey] ?? [];
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
                const SizedBox(height: 8),
                if (event['organisateurs'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: event['organisateurs'].map<Widget>((id) {
                      final association = context.read<EventProvider>().associations[id];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AssociationDetailPage(associationId: id),
                            ),
                          );
                        },
                        child: Text(
                          'Organized by: ${association?['name'] ?? 'Unknown'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      );
                    }).toList(),
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

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    if (eventProvider.events.isNotEmpty) {
      _groupEventsByDate(eventProvider.events);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendar',
          style: TextStyle(
            fontSize: 30,
            fontFamily: 'Lobster',
          ),
        ),
      ),
      body: eventProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2024, 01, 01),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  eventLoader: _getEventsForDay,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                  ),
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: ListView.builder(
                    itemCount: _getEventsForDay(_selectedDay).length,
                    itemBuilder: (context, index) {
                      var event = _getEventsForDay(_selectedDay)[index];
                      var associationNames = event['organisateurs']
                          .map((id) => context.read<EventProvider>().associations[id]?['name'])
                          .join(', ');
                      var associationImage = event['organisateurs']
                          .map((id) => context.read<EventProvider>().associations[id]?['image'])
                          .firstWhere((image) => image != null, orElse: () => null);
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: ListTile(
                          leading: associationImage != null
                              ? Image.network(
                                  associationImage,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.event),
                          title: Text(
                            event['nom_event'] ?? 'No Name',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            event['description'] ?? 'No Description',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(associationNames),
                          onTap: () {
                            _showEventDetails(event);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
