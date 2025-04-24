import '../../domain/entities/feed.dart';

class FeedModel extends Feed {
  const FeedModel({
    super.id,
    required super.url,
    required super.title,
    super.description,
    super.imageUrl,
    super.lastUpdated,
    super.website,
    super.isActive,
    super.updateFrequencyMinutes,
    super.category,
  });

  factory FeedModel.fromJson(Map<String, dynamic> json) {
    return FeedModel(
      id: json['id'],
      url: json['url'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
      website: json['website'],
      isActive: json['isActive'] == 1,
      updateFrequencyMinutes: json['updateFrequencyMinutes'] ?? 60,
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'website': website,
      'isActive': isActive ? 1 : 0,
      'updateFrequencyMinutes': updateFrequencyMinutes,
      'category': category,
    };
  }

  // Create a FeedModel from a domain Feed entity
  factory FeedModel.fromFeed(Feed feed) {
    return FeedModel(
      id: feed.id,
      url: feed.url,
      title: feed.title,
      description: feed.description,
      imageUrl: feed.imageUrl,
      lastUpdated: feed.lastUpdated,
      website: feed.website,
      isActive: feed.isActive,
      updateFrequencyMinutes: feed.updateFrequencyMinutes,
      category: feed.category,
    );
  }
}