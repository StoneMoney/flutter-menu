class ResturauntItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final int calories;

  const ResturauntItem(
      {required this.id,
      required this.name,
      required this.description,
      required this.price,
      required this.calories});

  factory ResturauntItem.fromJSON(Map<String, dynamic> json) {
    return ResturauntItem(
        id: json['id'],
        name: json['name'],
        description: json['description'] ?? 'No Description',
        price: json['price'] ?? 0.00,
        calories: json['calories'] ?? -1);
  }
}
