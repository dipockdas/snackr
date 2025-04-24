import 'package:equatable/equatable.dart';

/// Represents an individual item from a feed
class FeedItem extends Equatable {
  final int? id;
  final int feedId;
  final String title;
  final String? description;
  final String? content;
  final String? author;
  final String guid;
  final String? link;
  final DateTime publishDate;
  final bool isRead;
  final bool isStarred;
  final List<String>? categories;
  final String? imageUrl;

  const FeedItem({
    this.id,
    required this.feedId,
    required this.title,
    this.description,
    this.content,
    this.author,
    required this.guid,
    this.link,
    required this.publishDate,
    this.isRead = false,
    this.isStarred = false,
    this.categories,
    this.imageUrl,
  });

  FeedItem copyWith({
    int? id,
    int? feedId,
    String? title,
    String? description,
    String? content,
    String? author,
    String? guid,
    String? link,
    DateTime? publishDate,
    bool? isRead,
    bool? isStarred,
    List<String>? categories,
    String? imageUrl,
  }) {
    return FeedItem(
      id: id ?? this.id,
      feedId: feedId ?? this.feedId,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      author: author ?? this.author,
      guid: guid ?? this.guid,
      link: link ?? this.link,
      publishDate: publishDate ?? this.publishDate,
      isRead: isRead ?? this.isRead,
      isStarred: isStarred ?? this.isStarred,
      categories: categories ?? this.categories,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        feedId,
        title,
        description,
        content,
        author,
        guid,
        link,
        publishDate,
        isRead,
        isStarred,
        categories,
        imageUrl,
      ];
}