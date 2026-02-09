class Place {
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? placeId;

  Place({
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    this.placeId,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: json['latitude'],
      longitude: json['longitude'],
      placeId: json['placeId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'placeId': placeId,
    };
  }

  @override
  String toString() => '$name: $address';
}

class SavedPlace extends Place {
  final String icon;
  final String category;

  SavedPlace({
    required super.name,
    required super.address,
    super.latitude,
    super.longitude,
    super.placeId,
    required this.icon,
    required this.category,
  });

  factory SavedPlace.fromJson(Map<String, dynamic> json) {
    return SavedPlace(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: json['latitude'],
      longitude: json['longitude'],
      placeId: json['placeId'],
      icon: json['icon'] ?? 'location_on',
      category: json['category'] ?? 'other',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['icon'] = icon;
    json['category'] = category;
    return json;
  }
}

