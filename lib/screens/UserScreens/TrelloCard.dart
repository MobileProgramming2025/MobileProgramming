class TrelloCard {
  final String id;
  final String name;

  TrelloCard({required this.id, required this.name});

  factory TrelloCard.fromJson(Map<String, dynamic> json) {
    return TrelloCard(
      id: json['id'],
      name: json['name'],
    );
  }
}
