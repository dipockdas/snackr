import '../../domain/entities/feed_item.dart';

class FeedItemModel extends FeedItem {
  const FeedItemModel({
    super.id,
    required super.feedId,
    required super.title,
    super.description,
    super.content,
    super.author,
    required super.guid,
    super.link,
    required super.publishDate,
    super.isRead,
    super.isStarred,
    super.categories,
    super.imageUrl,
  });

  factory FeedItemModel.fromJson(Map<String, dynamic> json) {
    return FeedItemModel(
      id: json['id'],
      feedId: json['feedId'],
      title: json['title'],
      description: json['description'],
      content: json['content'],
      author: json['author'],
      guid: json['guid'],
      link: json['link'],
      publishDate: DateTime.parse(json['publishDate']),
      isRead: json['isRead'] == 1,
      isStarred: json['isStarred'] == 1,
      categories: json['categories'] != null
          ? List<String>.from(json['categories'].split(','))
          : null,
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'feedId': feedId,
      'title': title,
      'description': description,
      'content': content,
      'author': author,
      'guid': guid,
      'link': link,
      'publishDate': publishDate.toIso8601String(),
      'isRead': isRead ? 1 : 0,
      'isStarred': isStarred ? 1 : 0,
      'categories': categories?.join(','),
      'imageUrl': imageUrl,
    };
  }

  // Create a FeedItemModel from a domain FeedItem entity
  factory FeedItemModel.fromFeedItem(FeedItem item) {
    return FeedItemModel(
      id: item.id,
      feedId: item.feedId,
      title: item.title,
      description: item.description,
      content: item.content,
      author: item.author,
      guid: item.guid,
      link: item.link,
      publishDate: item.publishDate,
      isRead: item.isRead,
      isStarred: item.isStarred,
      categories: item.categories,
      imageUrl: item.imageUrl,
    );
  }
}