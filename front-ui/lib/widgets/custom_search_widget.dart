import 'package:flutter/material.dart';

class Search {
  static List<Map<String, dynamic>> filterAssociations(List<Map<String, dynamic>> associations, String query) {
    return associations.where((association) {
      final String name = association['name'].toString().toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();
  }
}
class CustomSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> associations;

  CustomSearchDelegate({required this.associations});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<Map<String, dynamic>> results = Search.filterAssociations(associations, query);
    return _buildResultList(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Map<String, dynamic>> suggestionList = Search.filterAssociations(associations, query);
    return _buildResultList(context, suggestionList);
  }

  Widget _buildResultList(BuildContext context, List<Map<String, dynamic>> resultList) {
    return ListView.builder(
      itemCount: resultList.length,
      itemBuilder: (context, index) {
        final association = resultList[index];
        return ListTile(
          title: Text(association['name']),
          onTap: () {
            close(context, association);
          },
        );
      },
    );
  }
}