import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobileprogramming/models/TrelloCard.dart';

class TrelloApi {
  final String _baseUrl =
      dotenv.env['BASE_URL'] ?? ""; // Base URL for Trello API
  final String _apiKey; // Your API key
  final String _token; // Your Trello token
  final String boardId; // The board ID

  TrelloApi(this.boardId)
      : _apiKey = dotenv.env['API_KEY'] ??
            'default-api-key', // Replace with your actual API key
        _token = dotenv.env['TOKEN'] ?? 'default-token';

  /// Fetches all cards from a specific list
  Future<List<TrelloCard>> fetchCards(String listId) async {
    final url = '$_baseUrl/lists/$listId/cards?key=$_apiKey&token=$_token';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((card) => TrelloCard.fromJson(card)).toList();
      } else {
        throw Exception(
            'Failed to load cards. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch cards: $e');
    }
  }

  /// Adds a new card to a specific list
  Future<void> addCard(String listId, String cardName) async {
    final url = '$_baseUrl/cards?key=$_apiKey&token=$_token';
    final body = {
      'idList': listId,
      'name': cardName,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to add card. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add card: $e');
    }
  }

  /// Deletes a specific card using its card ID
  Future<void> deleteCard(String cardId) async {
    final url = '$_baseUrl/cards/$cardId?key=$_apiKey&token=$_token';

    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to delete card. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete card: $e');
    }
  }
}
