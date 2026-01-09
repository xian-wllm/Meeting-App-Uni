// ========== IMPORTS ========== //
// Flutter
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:cloudinary/cloudinary.dart';
import 'package:auth0_flutter/auth0_flutter.dart';

// ========== PROFILE API SERVICE ========== //
class ProfileServiceAPI {
  final String baseUrl = 'https://pinfo2.unige.ch/api/profile';
  final storage = const FlutterSecureStorage();
  final cloudinary = Cloudinary.signedConfig(
    apiKey: dotenv.env['CLOUD_API_KEY']!,
    apiSecret: dotenv.env['CLOUD_API_SECRET']!,
    cloudName: dotenv.env['CLOUD_NAME']!,
  );

  // Get the access token from the storage.

  Future<String?> _getAccessToken() async {
    return await storage.read(key: 'accessToken');
  }

  // Get the user ID from the storage.

  Future<String?> _getUserId() async {
    return await storage.read(key: 'userId');
  }

  // ----- USER RESSOURCES ----- //
  
  // @GET
  // /utilisateur
  // Note : Fonction permettant de récupérer l'utilisateur actuellement connecté

  Future<http.Response> getUser() async {

    final accessToken = await _getAccessToken();
    final userId = await _getUserId();
    if (accessToken == null || userId == null) {
      await logout();
      throw Exception('No access token or user ID found');
    }

    print('accessToken: $accessToken');
    print('userId: $userId');

    final response = await http.get(
      Uri.parse('$baseUrl/utilisateur/$userId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    // print("Got user: ${response.statusCode}");
    return response;

  }

  // ###################################################

  // @GET
  // /utilisateur/{id}
  // Note : Fonction permettant de récupérer un utilisateur par son ID

  Future<http.Response> getUserByID(String id) async {

    final accessToken = await _getAccessToken();

    if (accessToken == null) {
      await logout();
      throw Exception('No access token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/utilisateur/$id'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    // print("Got user by ID: ${response.statusCode}");
    return response;

  }

  // ###################################################

  // @GET
  // /utilisateur/getName/{name}
  // Note : Fonction permettant de récupérer un utilisateur par son nom

  Future<http.Response> getUserByName(String name) async {

    final accessToken = await _getAccessToken();

    if (accessToken == null) {
      await logout();
      throw Exception('No access token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/utilisateur/getName/$name'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    // print("Got user by name: ${response.statusCode}");
    return response;

  }

  // ###################################################

  // @POST 
  // /utilisateur
  // Note : Fonction permettant de créer un utilisateur

  Future<http.Response> createUser(Map<String, dynamic> data) async {

    final accessToken = await _getAccessToken();
    final response = await http.post(
      Uri.parse('$baseUrl/utilisateur'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    // print("Created user: ${response.statusCode}");
    return response;

  }
  
  // ###################################################

  // @PUT
  // /utilisateur/profile/{id}
  // Note : Fonction permettant de mettre à jour le profil d'un utilisateur

  Future<http.Response> updateUser(Map<String, dynamic> data) async {

    final accessToken = await _getAccessToken();
    final userId = await _getUserId();

    if (accessToken == null || userId == null) {
      await logout();
      throw Exception('No access token or user ID found');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/utilisateur/profile/$userId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    // print("Updated user: ${response.statusCode}");
    return response;

  }

  // ###################################################

  // @DELETE
  // /utilisateur/{id}
  // Note : Fonction permettant de supprimer un utilisateur

  Future<http.Response> deleteUser(String id) async {

    final accessToken = await _getAccessToken();

    if (accessToken == null) {
      await logout();
      throw Exception('No access token found');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/utilisateur/$id'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    // print("Deleted user: ${response.statusCode}");
    return response;

  }

  // ###################################################

  // ----- MATCHES RESSOURCES ----- //

  // @GET 
  // /match/{id} 
  // Note : Fonction permettant de récupérer un match par son ID

  Future<http.Response> getMatchByID(String id) async {

    final accessToken = await _getAccessToken();

    if (accessToken == null || id == null) {
      throw Exception('No access token or user ID found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/match/$id'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      debugPrint('Failed to load match by ID: ${response.statusCode}');
    }

    // print('Got match by ID: ${response.statusCode}');
    return response;

  }

  // ###################################################

  // @GET 
  // /match/potentialMatches/{id}
  // Note : Fonction permettant de récupérer la liste des matchs potentiels

  Future<http.Response> getPotentialMatches() async {

    final accessToken = await _getAccessToken();
    final userId = await _getUserId();

    if (accessToken == null || userId == null) {
      throw Exception('No access token or user ID found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/match/potentialMatches/$userId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      }
    );

    if (response.statusCode != 200) {
      debugPrint('Failed to load potential matches: ${response.statusCode}');
    }

    // print('Got potential matches: ${response.statusCode}');
    return response;

  }

  // ###################################################

  // @POST 
  // /match/acceptMatch/{id}
  // Note : Fonction permettant d'accepter un match

  Future<http.Response> acceptMatch(String id) async {

    final accessToken = await _getAccessToken();

    if (accessToken == null || id == null) {
      throw Exception('No access token or user ID found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/match/acceptMatch/$id'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      }
    );

    if (response.statusCode != 200) {
      debugPrint('Fail to accept match: ${response.statusCode}');
    }

    // print('Accepted match: ${response.statusCode}');
    return response;

  }

  // ###################################################

  // @POST 
  // /match/refuseMatch/{id}
  // Note : Fonction permettant de refuser un match

  Future<http.Response> refuseMatch(String id) async {

    final accessToken = await _getAccessToken();

    if (accessToken == null || id == null) {
      throw Exception('No access token or user ID found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/match/refuseMatch/$id'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      }
    );

    if (response.statusCode != 200) {
      debugPrint('Fail to refuse match: ${response.statusCode}');
    }

    // print('Refused match: ${response.statusCode}');
    return response;
    
  }

  // ----- CLOUDINARY RESSOURCES ----- //

  // @UPLOAD
  // Note : Fonction permettant d'uploader une image de profil sur Cloudinary

  Future<String> uploadImageProfileToCloudinary(File imageFile) async {

    final response = await cloudinary.upload(
      file: imageFile.path,
      resourceType: CloudinaryResourceType.image,
    );

    if (response.isSuccessful) {
      return response.secureUrl!;
    } else {
      throw Exception('Failed to upload image: ${response.error ?? 'Unknown error'}');
    }

  }

  // ###################################################

  // @UPDATE
  // Note : Fonction permettant de mettre à jour l'image de profil d'un utilisateur

  Future<http.Response> updateImageProfile(Map<String, dynamic> user, String imageUrl) async {
    final accessToken = await _getAccessToken();
    final userId = await _getUserId();
    if (accessToken == null || userId == null) {
      await logout();
      throw Exception('No access token or user ID found');
    }

    user['profilePic'] = imageUrl;
    final data = user;

    final response = await http.put(
      Uri.parse('$baseUrl/utilisateur/profile/$userId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    // print("Updated profile image: ${response.statusCode}");
    return response;

  }

  // ###################################################

  // ----- OTHER RESSOURCES ----- //

  // @UPDATE MATCH
  // Note : Fonction permettant de mettre à jour le match d'un utilisateur

  Future<http.Response> updateMatchProfile(Map<String, dynamic> user, bool match) async {

    final accessToken = await _getAccessToken();
    final userId = await _getUserId();
    if (accessToken == null || userId == null) {
      await logout();
      throw Exception('No access token or user ID found');
    }

    user['match'] = match;
    final data = user;

    final response = await http.put(
      Uri.parse('$baseUrl/utilisateur/profile/$userId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    // print("Updated match: ${response.statusCode}");
    return response;

  }

  // ###################################################

  // @LOGOUT
  // Note : Fonction permettant de déconnecter un utilisateur

  Future<void> logout() async {

    final auth0 = Auth0(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);
    await auth0.webAuthentication().logout();
    await storage.deleteAll();

  }

  // ###################################################

  // @BLOCK
  // Note : Fonction permettant de bloquer un utilisateur

  Future<http.Response> blockUser(String userIdToBlock) async {

    final accessToken = await _getAccessToken();
    final userId = await _getUserId();
    if (accessToken == null || userId == null) {
      await logout();
      throw Exception('No access token or user ID found');
    }

    final userResponse = await getUser();
    if (userResponse.statusCode != 200) {
      throw Exception('Failed to get user data');
    }

    final userData = jsonDecode(userResponse.body);
    List<String> blockedUsers = List<String>.from(userData['blockedUsers']);
    blockedUsers.add(userIdToBlock);

    userData['blockedUsers'] = blockedUsers;

    final response = await http.put(
      Uri.parse('$baseUrl/utilisateur/profile/$userId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(userData),
    );

    // print("Blocked user: ${response.statusCode}");
    return response;

  }

}
