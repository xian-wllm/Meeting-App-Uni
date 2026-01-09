// ========== IMPORTS ========== //
// Flutter
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

// ========== MESSAGERIE API SERVICE ========== //
class MessagerieServiceAPI {
  final String baseUrl = 'https://pinfo2.unige.ch/api/messagerie';
  final storage = const FlutterSecureStorage();

  Future<String?> _getAccessToken() async {
    return await storage.read(key: 'accessToken');
  }

  Future<String?> _getUserId() async {
    return await storage.read(key: 'userId');
  }

  // ----- MESSAGERIE RESSOURCES ----- //

  // @GET
  // /messagerie/user/{idUser}
  // Note : Fonction permettant de récupérer la liste des messageries d'un utilisateur

  Future<http.Response> getMessagerieByUserID() async {

    final accessToken = await _getAccessToken();
    final idUser = await _getUserId();
    final response = await http.get(
      Uri.parse('$baseUrl/messagerie/user/$idUser'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    // print("Listed messageries: ${response.statusCode}");
    return response;

  }

  // ###################################################

  // @GET
  // /messagerie/{id}
  // Note : Fonction permettant de récupérer une messagerie par son ID

  Future<http.Response> getMessagerieByID(int id) async {

    final accessToken = await _getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/messagerie/$id'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    // print("Got messagerie by ID: ${response.statusCode}");
    return response;

  }

  // ###################################################

  // @POST
  // /messagerie
  // Note : Fonction permettant de créer une messagerie

  Future<http.Response> createMessagerie(Map<String, dynamic> data) async {
    final accessToken = await _getAccessToken();
    final response = await http.post(
      Uri.parse('$baseUrl/messagerie'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    // print("Created messagerie: ${response.statusCode}");
    return response;

  }

  // ###################################################

  // @PUT
  // /messagerie/{id}
  // Note : Fonction permettant de mettre à jour une messagerie

  Future<http.Response> updateMessagerie(int id, Map<String, dynamic> data) async {

    final accessToken = await _getAccessToken();
    final response = await http.put(
      Uri.parse('$baseUrl/messagerie/${data['messagerie_id']}'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    // print("Updated messagerie: ${response.statusCode}");
    return response;

  }

  // ###################################################

  // @DELETE
  // /messagerie/{id}
  // Note : Fonction permettant de supprimer une messagerie

  Future<http.Response> deleteMessagerie(int id) async {

    final accessToken = await _getAccessToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/messagerie/$id'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    // print("Deleted messagerie: ${response.statusCode}");
    return response;

  }

  // ###################################################

  // ----- MESSAGE RESSOURCES ----- //

  // @GET
  // /message/messagerie/{id}
  // Note : Fonction permettant de récupérer la liste des messages d'une messagerie

  Future<http.Response> getMessageByMessagerieID(int id) async {

    final accessToken = await _getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/message/messagerie/$id'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    // print("Listed messages: ${response.statusCode}");
    return response;

  }

  // ###################################################

  // @GET
  // /message/{id}
  // Note : Fonction permettant de récupérer un message par son ID

  Future<http.Response> getMessageByID(int id) async {

    final accessToken = await _getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/message/$id'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    // print("Got message by ID: ${response.statusCode}");
    return response;
  }

  // ###################################################

  // @POST
  // /message/{id}
  // Note : Fonction permettant de créer un message

  Future<http.Response> createMessage(int id, Map<String, dynamic> data) async {

    final accessToken = await _getAccessToken();
    final response = await http.post(
      Uri.parse('$baseUrl/message/$id'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    // print("Created message: ${response.statusCode}");
    return response;

  }

  // ###################################################

  // @DELETE
  // /message/{messagerieId}/{id}
  // Note : Fonction permettant de supprimer un message

  Future<http.Response> deleteMessage(int messagerieId, int id) async {

    final accessToken = await _getAccessToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/message/$messagerieId/$id'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    // print("Deleted message: ${response.statusCode}");
    return response;

  }

}
