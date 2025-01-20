import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mobileprogramming/models/TrelloCard.dart';


class TrelloApi {
String _baseUrl = dotenv.env['BASE_URL'] ?? 'https://default-url.com';
String _token = dotenv.env['TOKEN'] ?? 'default-token';
String _apiKey = dotenv.env['API_KEY'] ?? 'default-api-key';
  final String boardId; // ID of the Trello board

  TrelloApi(this.boardId);

  Future<List<TrelloCard>> fetchCards(String listId) async {
    final url =
        '$_baseUrl/lists/$listId/cards?key=$_apiKey&token=$_token';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((card) => TrelloCard.fromJson(card)).toList();
      } else {
        throw Exception('Failed to load cards. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch cards: $e');
    }
  }

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
        throw Exception('Failed to add card. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add card: $e');
    }
  }
}







