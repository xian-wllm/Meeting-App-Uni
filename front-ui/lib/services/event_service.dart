// ========== IMPORTS ========== //
// Flutter
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

// ========== EVENT API SERVICE ========== //
class EventServiceAPI {
  final String baseUrl = 'https://pinfo2.unige.ch/api/events';
  final storage = const FlutterSecureStorage();

  // Get the access token from the storage.
  
  Future<String?> _getAccessToken() async {
    return await storage.read(key: 'accessToken');
  }

  // ----- EVENT RESSOURCES ----- //

  // @GET
  // /event
  // Note : Fonction permettant de récupérer la liste de tous les événements

  Future<http.Response> getListEvents() async {

    final accessToken = await _getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/event'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    // print("Listed events: ${response.statusCode}");
    return response;

  }

  // ###################################################

  // @GET
  // /event/{id}
  // Note : Fonction permettant de récupérer un événement par son ID

  Future<http.Response> getEventByID(int id) async {

    final accessToken = await _getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/event/$id'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    // print("Got event by ID: ${response.statusCode}");
    return response;

  }

  // ###################################################

  // @GET
  // /event/findByAsso/{id}
  // Note : Fonction permettant de récupérer la liste des événements par l'ID de l'association

  Future<http.Response> getEventsByAssociationID(int id) async {

    final accessToken = await _getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/event/findByAsso/$id'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    // print("Got events by association ID: ${response.statusCode}");
    return response;

  }

  // ###################################################

  // @GET
  // /event/findByTags/{tag}
  // Note : Fonction permettant de récupérer la liste des événements par tag

  Future<http.Response> getEventsByTag(String tag) async {

    final accessToken = await _getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/event/findByTags/$tag'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    // print("Got events by tag: ${response.statusCode}");
    return response;

  }

  // ###################################################

  // @POST
  // /event
  // Note : Fonction permettant de créer un événement

  Future<http.Response> createEvent(Map<String, dynamic> data) async {

    final accessToken = await _getAccessToken();
    final response = await http.post(
      Uri.parse('$baseUrl/event'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    // print("Created event: ${response.statusCode}");
    return response;

  }

  // ###################################################

  // @POST
  // /event/findByTags
  // Note : Fonction permettant de créer un événement par tag
  
  Future<http.Response> createEventByTag(Map<String, dynamic> data) async {

    final accessToken = await _getAccessToken();
    final response = await http.post(
      Uri.parse('$baseUrl/event/findByTags'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    // print("Created event by tag: ${response.statusCode}");
    return response;

  }

  // ###################################################
  
  // @PUT
  // /event/{id}
  // Note : Fonction permettant de mettre à jour un événement

  Future<http.Response> updateEvent(Map<String, dynamic> data) async {

    final accessToken = await _getAccessToken();
    final response = await http.put(
      Uri.parse('$baseUrl/event/${data['event_id']}'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    // print("Updated event: ${response.statusCode}");
    return response;

  }

  // ###################################################
  
  // @DELETE
  // /event/{id}
  // Note : Fonction permettant de supprimer un événement

  Future<http.Response> deleteEvent(int id) async {

    final accessToken = await _getAccessToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/event/$id'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    // print("Deleted event: ${response.statusCode}");
    return response;

  }
}