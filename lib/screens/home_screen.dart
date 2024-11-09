import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';

class Character {
  final String name;
  final String imageUrl;
  final String description;
  final String house;

  Character({
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.house,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      name: json['name'] ?? 'Unknown',
      imageUrl: json['image'] ?? '',
      description: json['description'] ?? 'No description available',
      house: json['house'] ?? 'No house available',
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Character>> fetchCharacters() async {
    final response = await http.get(Uri.parse('https://hp-api.onrender.com/api/characters/staff'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Character.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load characters');
    }
  }

  late Future<List<Character>> future;

  @override
  void initState() {
    super.initState();
    future = fetchCharacters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unit 7 - API Calls"),
      ),
      body: FutureBuilder<List<Character>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data found'));
          }

          final characters = snapshot.data!;
          return ListView.builder(
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final character = characters[index];

              
              final controller = ExpandedTileController();

              return ExpandedTile(
                controller: controller, 
                title: Text(character.name),
                leading: character.imageUrl.isNotEmpty
                    ? Image.network(character.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                    : Icon(Icons.person),
             
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(character.description),
                      SizedBox(height: 8),
                      Text("House: ${character.house}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}