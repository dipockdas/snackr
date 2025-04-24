import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/feed_model.dart';
import '../models/feed_item_model.dart';

abstract class FeedRemoteDataSource {
  Future<FeedModel> fetchFeedMetadata(String url);
  Future<List<FeedItemModel>> fetchFeedItems(String url, int feedId);
}

class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  final http.Client client;

  FeedRemoteDataSourceImpl({required this.client});

  @override
  Future<FeedModel> fetchFeedMetadata(String url) async {
    final response = await client.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      // For the simplicity of our prototype, we'll implement a very basic RSS parser
      // In a real implementation, you would use a proper RSS/Atom parser
      
      final body = response.body;
      
      // Extract feed title
      final titleRegex = RegExp(r'<title>(.*?)<\/title>');
      final titleMatch = titleRegex.firstMatch(body);
      final title = titleMatch?.group(1) ?? 'Untitled Feed';
      
      // Extract feed description
      final descRegex = RegExp(r'<description>(.*?)<\/description>');
      final descMatch = descRegex.firstMatch(body);
      final description = descMatch?.group(1);
      
      // Extract feed link
      final linkRegex = RegExp(r'<link>(.*?)<\/link>');
      final linkMatch = linkRegex.firstMatch(body);
      final website = linkMatch?.group(1);
      
      return FeedModel(
        url: url,
        title: title,
        description: description,
        website: website,
      );
    } else {
      throw Exception('Failed to load feed: ${response.statusCode}');
    }
  }

  @override
  Future<List<FeedItemModel>> fetchFeedItems(String url, int feedId) async {
    final response = await client.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      // Simple RSS item extraction for prototype
      final body = response.body;
      final items = <FeedItemModel>[];
      
      // Extract all item blocks
      final itemRegex = RegExp(r'<item>(.*?)<\/item>', dotAll: true);
      final itemMatches = itemRegex.allMatches(body);
      
      for (final match in itemMatches) {
        final itemContent = match.group(1) ?? '';
        
        // Extract item title
        final titleRegex = RegExp(r'<title>(.*?)<\/title>');
        final titleMatch = titleRegex.firstMatch(itemContent);
        final title = titleMatch?.group(1) ?? 'Untitled Item';
        
        // Extract item description
        final descRegex = RegExp(r'<description>(.*?)<\/description>', dotAll: true);
        final descMatch = descRegex.firstMatch(itemContent);
        final description = descMatch?.group(1);
        
        // Extract item link
        final linkRegex = RegExp(r'<link>(.*?)<\/link>');
        final linkMatch = linkRegex.firstMatch(itemContent);
        final link = linkMatch?.group(1);
        
        // Extract guid
        final guidRegex = RegExp(r'<guid>(.*?)<\/guid>');
        final guidMatch = guidRegex.firstMatch(itemContent);
        final guid = guidMatch?.group(1) ?? link ?? DateTime.now().toIso8601String();
        
        // Extract pubDate
        final dateRegex = RegExp(r'<pubDate>(.*?)<\/pubDate>');
        final dateMatch = dateRegex.firstMatch(itemContent);
        final dateStr = dateMatch?.group(1);
        DateTime? pubDate;
        
        if (dateStr != null) {
          try {
            pubDate = DateTime.parse(dateStr);
          } catch (e) {
            // If can't parse, use current time
            pubDate = DateTime.now();
          }
        } else {
          pubDate = DateTime.now();
        }
        
        items.add(FeedItemModel(
          feedId: feedId,
          title: title,
          description: description,
          guid: guid,
          link: link,
          publishDate: pubDate,
        ));
      }
      
      return items;
    } else {
      throw Exception('Failed to load feed items: ${response.statusCode}');
    }
  }
}