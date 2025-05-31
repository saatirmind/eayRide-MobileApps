class TouristAttraction {
  final int id;
  final String title;
  final String thumbnail;
  final double latitude;
  final double longitude;
  final double distance;

  TouristAttraction({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.latitude,
    required this.longitude,
    required this.distance,
  });

  factory TouristAttraction.fromJson(Map<String, dynamic> json) {
    return TouristAttraction(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown',
      thumbnail: json['thumbnail'] ?? '',
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      distance: double.tryParse(json['distance_km'].toString()) ?? 0.0,
    );
  }
}
