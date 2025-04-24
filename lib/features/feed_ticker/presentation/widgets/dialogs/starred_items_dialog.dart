import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/utils/html_utils.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../core/utils/popup_window.dart';
import '../../../domain/entities/feed_item.dart';
import '../../providers/feed_providers.dart';
import 'dialog_window_manager.dart';

class StarredItemsDialog extends ConsumerWidget {
  const StarredItemsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(feedItemsNotifierProvider());
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Starred Items',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: itemsAsync.when(
              data: (items) {
                final starredItems = items.where((item) => item.isStarred).toList();
                
                if (starredItems.isEmpty) {
                  return const Center(
                    child: Text(
                      'No starred items yet',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: starredItems.length,
                  itemBuilder: (context, index) {
                    final item = starredItems[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: Colors.black54,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Text(
                          HtmlUtils.decodeHtml(item.title),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Feed #${item.feedId}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                        leading: item.imageUrl != null
                            ? SizedBox(
                                width: 60,
                                height: 60,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    item.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.image_not_supported, size: 30, color: Colors.white54);
                                    },
                                  ),
                                ),
                              )
                            : const Icon(Icons.star, size: 30, color: Colors.amber),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            ref.read(feedItemsNotifierProvider().notifier).toggleStar(item.id!, true);
                          },
                        ),
                        onTap: () {
                          _showItemDetail(context, item, ref);
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Error loading starred items: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                onPressed: () {
                  ref.read(dialogWindowManagerProvider).closeDialog('starred_items_dialog');
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showItemDetail(BuildContext context, FeedItem item, WidgetRef ref) {
    // Debug the item contents
    AppLogger.info('Showing starred item detail: ${item.title}');
    
    // Show detailed view using full-screen popup
    PopupWindow.show(
      context: context,
      builder: (context) => Container(
        width: 800,
        height: 600,
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              HtmlUtils.decodeHtml(item.title),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            if (item.author != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  'By ${item.author}',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            if (item.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                      const SizedBox(height: 0),
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: item.content != null
                  ? Text(
                      HtmlUtils.decodeHtml(item.content!),
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    )
                  : item.description != null
                    ? Text(
                        HtmlUtils.decodeHtml(item.description!),
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      )
                    : const Text(
                        'No content available',
                        style: TextStyle(color: Colors.white70),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            if (item.link != null)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () async {
                  final url = Uri.parse(item.link!);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    AppLogger.error('Could not launch ${item.link}');
                  }
                },
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Open in Browser'),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  onPressed: () {
                    ref.read(feedItemsNotifierProvider().notifier).toggleStar(item.id!, true);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Remove Star'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}