// ===== IMPORTS ===== //
// Fluter
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:cloudinary/cloudinary.dart';

// ========== ASSOCIATION API SERVICE ========== //
class AssociationServiceAPI {
  final String baseUrl = 'https://pinfo2.unige.ch/api/associations';
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

  // Get the association ID from the storage.

  Future<int?> _getAssociationId() async {
    final id = await storage.read(key: 'assoId');
    return id != null ? int.parse(id) : null;
  }

  // ----- ASSOCIATION RESSOURCES ----- //

  // @GET
  // /associations
  // Note : Fonction permettant de récupérer la liste de toutes les associations

  Future<http.Response> getListAssociations() async {

    final accessToken = await _getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/association'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    // print("Listed associations: ${response.statusCode}");
    return response;

  }

  // ###################################################

  // @GET
  // /association/findById/{id}
  // Note : Fonction permettant de récupérer une association par son ID

  Future<http.Response> getAssociationByID(int id) async {

    final accessToken = await _getAccessToken();
    final response = await http.get( 
      Uri.parse('$baseUrl/association/findById/$id'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json', 
      },
    );

    // print("Got association by ID: ${response.statusCode}");
    return response;

  }

  // ###################################################

  // @GET
  // /association/findByTags/{tags}
  // Note : Fonction permettant de récupérer une association par ses tags

  Future<http.Response> getAssociationByTags(List<String> tags) async {

    final accessToken = await _getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/association/findByTags/$tags'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    // print("Got association by tags: ${response.statusCode}");
    return response;

  }

  // ###################################################

  // @POST
  // /association
  // Note : Fonction permettant de créer une association

  Future<http.Response> createAssociation(Map<String, dynamic> data) async {

    final accessToken = await _getAccessToken();
    final response = await http.post(
      Uri.parse('$baseUrl/association'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    // print("Created association: ${response.statusCode}");
    return response;

  }

  // ###################################################

  // @PUT
  // /association/{id}
  // Note : Fonction permettant de mettre à jour une association

  Future<http.Response> updateAssociation(Map<String, dynamic> data) async {

    final accessToken = await _getAccessToken();
    final response = await http.put(
      Uri.parse('$baseUrl/association/${data['asso_id']}'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    // print("Updated association: ${response.statusCode}");
    return response;

  }

  // ###################################################

  // @DELETE
  // /association/{id}
  // Note : Fonction permettant de supprimer une association

  Future<http.Response> deleteAssociation(int id) async {

    final accessToken = await _getAccessToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/association/$id'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    // print("Deleted association: ${response.statusCode}");
    return response;

  }

  // ###################################################

  // ----- CLOUDINARY RESSOURCES ----- //

  // @UPLOAD
  // Note : Fonction permettant d'uploader une image d'association sur Cloudinary

  Future<String> uploadImageAssociationToCloudinary(File imageAssociationFile) async {

    final response = await cloudinary.upload(
      file: imageAssociationFile.path,
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
  // Note : Fonction permettant de mettre à jour l'image d'une association

  Future<http.Response> updateImageAssociation(Map<String, dynamic> assoc, String imageUrl) async {

    final accessToken = await _getAccessToken();
    final assocId = await _getAssociationId();
    if (accessToken == null || assocId == null) {
      throw Exception('No access token or association ID found');
    }

    assoc['image'] = imageUrl;
    final data = assoc;

    final response = await http.put(
      Uri.parse('$baseUrl/association/$assocId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    // print("Updated association image: ${response.statusCode}");
    return response;

  }
}
