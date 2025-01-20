/// TrelloCard model class to represent individual cards
class TrelloCard {
  final String id;
  final String name;

  TrelloCard({required this.id, required this.name});

  /// Factory method to create a TrelloCard from JSON
  factory TrelloCard.fromJson(Map<String, dynamic> json) {
    return TrelloCard(
      id: json['id'],
      name: json['name'],
    );
  }
}