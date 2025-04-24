import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/html_utils.dart';
import '../../domain/entities/feed_item.dart';

class TickerItem extends StatelessWidget {
  final FeedItem item;
  final VoidCallback onTap;
  final VoidCallback onReadToggle;
  final VoidCallback onStarToggle;
  final bool showImage;

  const TickerItem({
    Key? key,
    required this.item,
    required this.onTap,
    required this.onReadToggle,
    required this.onStarToggle,
    this.showImage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Debug output to see what's in the feed item
    final decodedTitle = HtmlUtils.decodeHtml(item.title);
    print('Building ticker item: ${item.title} -> Decoded: $decodedTitle');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 200, maxWidth: 500, minHeight: 80),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showImage && item.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(7),
                  bottomLeft: Radius.circular(7),
                ),
                child: Image.network(
                  item.imageUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      width: 80,
                      height: 80,
                      child: Icon(Icons.image_not_supported, color: Colors.white30),
                    );
                  },
                ),
              ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      decodedTitle.isNotEmpty ? decodedTitle : "Untitled",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        decoration: item.isRead ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.description != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          HtmlUtils.decodeHtml(item.description!) ?? "No description",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    item.isStarred ? Icons.star : Icons.star_border,
                    color: item.isStarred ? Colors.amber : Colors.white,
                  ),
                  onPressed: onStarToggle,
                ),
                IconButton(
                  icon: Icon(
                    item.isRead ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white,
                  ),
                  onPressed: onReadToggle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // We're keeping this for backward compatibility but using our new utility
  String _stripHtml(String htmlString) {
    return HtmlUtils.decodeHtml(htmlString);
  }
}