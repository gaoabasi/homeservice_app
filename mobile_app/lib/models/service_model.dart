class ServiceModel {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String iconName;
  final double basePrice;

  ServiceModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.iconName,
    required this.basePrice,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'] ?? '',
      iconName: json['icon_name'] ?? 'handyman',
      basePrice: double.parse(json['base_price'].toString()),
    );
  }
}
