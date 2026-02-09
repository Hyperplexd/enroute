class Podcast {
  final String id;
  final String title;
  final String category;
  final int durationSeconds;
  final String? audioUrl;
  final String? transcript;
  final String? imageUrl;
  final DateTime createdAt;
  final PodcastType type;
  final String topic;

  Podcast({
    required this.id,
    required this.title,
    required this.category,
    required this.durationSeconds,
    this.audioUrl,
    this.transcript,
    this.imageUrl,
    required this.createdAt,
    required this.type,
    required this.topic,
  });

  int get durationMinutes => (durationSeconds / 60).round();

  factory Podcast.fromJson(Map<String, dynamic> json) {
    return Podcast(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      durationSeconds: json['durationSeconds'] ?? 0,
      audioUrl: json['audioUrl'],
      transcript: json['transcript'],
      imageUrl: json['imageUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      type: PodcastType.values.firstWhere(
        (e) => e.toString() == 'PodcastType.${json['type']}',
        orElse: () => PodcastType.exploreTopic,
      ),
      topic: json['topic'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'durationSeconds': durationSeconds,
      'audioUrl': audioUrl,
      'transcript': transcript,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'type': type.toString().split('.').last,
      'topic': topic,
    };
  }
}

enum PodcastType {
  exploreTopic,
  microDegree,
}

