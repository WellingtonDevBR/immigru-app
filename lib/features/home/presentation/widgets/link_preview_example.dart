import 'package:flutter/material.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:logger/logger.dart';
import 'package:immigru/shared/widgets/in_app_browser.dart';

/// A widget that demonstrates the link preview functionality
class LinkPreviewExample extends StatelessWidget {
  final String link;
  final Logger _logger = Logger();

  LinkPreviewExample({
    super.key,
    required this.link,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Link Preview Example',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            AnyLinkPreview(
              link: link,
              displayDirection: UIDirection.uiDirectionHorizontal,
              showMultimedia: true,
              bodyMaxLines: 3,
              bodyTextOverflow: TextOverflow.ellipsis,
              titleStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              bodyStyle: TextStyle(color: Colors.grey[700], fontSize: 12),
              backgroundColor: Colors.white,
              errorBody: 'Could not load preview for this link',
              errorTitle: 'Error loading preview',
              errorWidget: Container(
                color: Colors.grey[300],
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  'Unable to load preview',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              cache: const Duration(days: 7),
              borderRadius: 12,
              removeElevation: false,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 3,
                  color: Colors.black12,
                  offset: Offset(0, 1),
                )
              ],
              onTap: () {
                _logger.d('Link tapped: $link');
                _showConfirmationDialog(context, link);
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Tap on the preview to open the link in the in-app browser',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows a confirmation dialog before opening the link
  void _showConfirmationDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open Link?'),
        content: const Text(
          'Would you like to open this link?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openInAppBrowser(context, url);
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  /// Opens the link in the in-app browser
  void _openInAppBrowser(BuildContext context, String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InAppBrowser(
          url: url,
          title: 'Web View',
        ),
      ),
    );
  }
}
