import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:Spark/services/event_service.dart';
import 'package:Spark/services/association_service.dart';

class EventProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _events = [];
  Map<int, Map<String, dynamic>> _associations = {};
  final EventServiceAPI _eventServiceAPI = EventServiceAPI();
  final AssociationServiceAPI _associationServiceAPI = AssociationServiceAPI();
  bool _isLoading = false;

  List<Map<String, dynamic>> get events => _events;
  Map<int, Map<String, dynamic>> get associations => _associations;
  bool get isLoading => _isLoading;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> fetchAllEvents() async {
    _setLoading(true);
    try {
      final response = await _eventServiceAPI.getListEvents();
      if (response.statusCode == 200) {
        _events = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        await _fetchAssociationDetails();
      } else {
        // Handle error
        print('Failed to load events');
      }
    } catch (e) {
      print('Error fetching events: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _fetchAssociationDetails() async {
    final associationsToFetch = _events.expand((event) => event['organisateurs']).toSet();
    for (int associationId in associationsToFetch) {
      if (!_associations.containsKey(associationId)) {
        final response = await _associationServiceAPI.getAssociationByID(associationId);
        if (response.statusCode == 200) {
          final association = jsonDecode(response.body) as Map<String, dynamic>;
          _associations[associationId] = association;
        } else {
          print('Failed to fetch association details: ${response.statusCode}');
        }
      }
    }
    notifyListeners();
  }

  void addEvent(Map<String, dynamic> event) {
    _events.removeWhere((existingEvent) => existingEvent['event_id'] == event['event_id']);
    _events.add(event);
    notifyListeners();
  }

  void setEvents(List<Map<String, dynamic>> events) {
    _events = events;
    notifyListeners();
  }
}