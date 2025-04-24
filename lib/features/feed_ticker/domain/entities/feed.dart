import 'package:equatable/equatable.dart';

/// Represents a feed source with its metadata
class Feed extends Equatable {
  final int? id;
  final String url;
  final String title;
  final String? description;
  final String? imageUrl;
  final DateTime? lastUpdated;
  final String? website;
  final bool isActive;
  final int updateFrequencyMinutes;
  final String? category;

  const Feed({
    this.id,
    required this.url,
    required this.title,
    this.description,
    this.imageUrl,
    this.lastUpdated,
    this.website,
    this.isActive = true,
    this.updateFrequencyMinutes = 60,
    this.category,
  });

  Feed copyWith({
    int? id,
    String? url,
    String? title,
    String? description,
    String? imageUrl,
    DateTime? lastUpdated,
    String? website,
    bool? isActive,
    int? updateFrequencyMinutes,
    String? category,
  }) {
    return Feed(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      website: website ?? this.website,
      isActive: isActive ?? this.isActive,
      updateFrequencyMinutes: updateFrequencyMinutes ?? this.updateFrequencyMinutes,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [
        id,
        url,
        title,
        description,
        imageUrl,
        lastUpdated,
        website,
        isActive,
        updateFrequencyMinutes,
        category,
      ];
}