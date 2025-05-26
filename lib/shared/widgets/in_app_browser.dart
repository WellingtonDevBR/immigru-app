import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// A screen that displays web content within the app
class InAppBrowser extends StatefulWidget {
  final String url;
  final String title;

  const InAppBrowser({
    super.key,
    required this.url,
    this.title = 'Web View',
  });

  @override
  State<InAppBrowser> createState() => _InAppBrowserState();
}

class _InAppBrowserState extends State<InAppBrowser> {
  final _logger = Logger();
  double _progress = 0;
  String _currentUrl = '';
  String _pageTitle = '';
  bool _isLoading = true;

  // Controller for the web view
  InAppWebViewController? _webViewController;
  PullToRefreshController? _pullToRefreshController;

  @override
  void initState() {
    super.initState();
    _currentUrl = _normalizeUrl(widget.url);
    _logger.d('Normalized URL: $_currentUrl');

    // Initialize pull-to-refresh controller
    _pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Colors
            .blue, // Use a default color instead of accessing Theme in initState
      ),
      onRefresh: () async {
        _refreshPage();
      },
    );
  }

  /// Normalizes URL to ensure it has proper format
  String _normalizeUrl(String url) {
    // Trim any whitespace
    String normalizedUrl = url.trim();

    // Ensure URL has http/https prefix
    if (!normalizedUrl.startsWith('http://') &&
        !normalizedUrl.startsWith('https://')) {
      normalizedUrl = 'https://$normalizedUrl';
    }

    // Handle specific domains that require www prefix
    if (normalizedUrl.contains('mercadolivre.com') &&
        !normalizedUrl.contains('www.')) {
      normalizedUrl = normalizedUrl.replaceFirst('https://', 'https://www.');
    }

    _logger.d('Original URL: $url, Normalized: $normalizedUrl');
    return normalizedUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitle.isNotEmpty ? _pageTitle : widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            // Try to go back in web history first
            if (_webViewController != null &&
                await _webViewController!.canGoBack()) {
              _webViewController!.goBack();
            } else {
              // After async operation, check if widget is still mounted
              if (mounted) {
                // Use the current context directly after mounted check
                Navigator.of(context).pop();
              }
            }
          },
        ),
        actions: [
          // Forward navigation button
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () async {
              if (_webViewController != null &&
                  await _webViewController!.canGoForward()) {
                _webViewController!.goForward();
              }
            },
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _refreshPage();
            },
          ),
          // More options button
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'external':
                  _confirmOpenInExternalBrowser();
                  break;
                case 'share':
                  _shareUrl();
                  break;
                case 'copy':
                  _copyUrlToClipboard();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'external',
                child: Row(
                  children: [
                    Icon(Icons.open_in_browser),
                    SizedBox(width: 8),
                    Text('Open in browser'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share link'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.content_copy),
                    SizedBox(width: 8),
                    Text('Copy link'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          if (_isLoading)
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          // Web view
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(_currentUrl)),
              initialSettings: InAppWebViewSettings(
                // Cross-platform options
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
                javaScriptEnabled: true,
                javaScriptCanOpenWindowsAutomatically: true,
                cacheEnabled: true,
                preferredContentMode: UserPreferredContentMode.RECOMMENDED,
                supportZoom: true,
                allowFileAccessFromFileURLs: true,
                allowUniversalAccessFromFileURLs: true,
                verticalScrollBarEnabled: true,
                horizontalScrollBarEnabled: true,

                // Android-specific options
                useHybridComposition: true,
                domStorageEnabled: true,
                databaseEnabled: true,
                supportMultipleWindows: true,
                allowContentAccess: true,
                allowFileAccess: true,
                builtInZoomControls: true,
                displayZoomControls: false,
                loadWithOverviewMode: true,
                useWideViewPort: true,

                // iOS-specific options
                allowsInlineMediaPlayback: true,
                allowsBackForwardNavigationGestures: true,
                allowsLinkPreview: true,
                isFraudulentWebsiteWarningEnabled: true,
                enableViewportScale: true,
                allowsPictureInPictureMediaPlayback: true,
              ),
              pullToRefreshController: _pullToRefreshController,
              onWebViewCreated: (controller) {
                _webViewController = controller;
                _logger.d('WebView created');
              },
              onLoadStart: (controller, url) {
                setState(() {
                  _isLoading = true;
                  _currentUrl = url.toString();
                });
                _logger.d('Page load started: $url');
              },
              onLoadStop: (controller, url) async {
                final refreshController = _pullToRefreshController;
                if (refreshController != null) {
                  refreshController.endRefreshing();
                }

                setState(() {
                  _isLoading = false;
                  _currentUrl = url.toString();
                });
                _logger.d('Page load completed: $url');

                // Get page title
                final title = await controller.getTitle();
                if (title != null && mounted) {
                  setState(() {
                    _pageTitle = title;
                  });
                }
              },
              onProgressChanged: (controller, progress) {
                if (progress == 100 && _pullToRefreshController != null) {
                  _pullToRefreshController!.endRefreshing();
                }
                setState(() {
                  _progress = progress / 100;
                  _isLoading = progress < 100;
                });
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final uri = navigationAction.request.url;
                if (uri == null) return NavigationActionPolicy.CANCEL;

                final url = uri.toString();
                _logger.d('Intercepted URL: $url');

                // Handle standard HTTP/HTTPS URLs
                if (url.startsWith('http://') || url.startsWith('https://')) {
                  // Allow standard web URLs to load normally
                  return NavigationActionPolicy.ALLOW;
                }

                // Handle custom schemes and special URLs
                _logger.d('Detected non-standard URL scheme: $url');

                try {
                  // Properly parse the URL and handle special cases
                  final uri = Uri.parse(url);

                  // Log the attempt for debugging
                  _logger.d('Attempting to launch external app with URI: $uri');
                  _logger.d(
                      'URI scheme: ${uri.scheme}, path: ${uri.path}, query: ${uri.query}');

                  // Check if the URL can be launched
                  final canLaunch = await canLaunchUrl(uri);

                  if (canLaunch) {
                    // Launch the URL with the appropriate app
                    final launched = await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );

                    if (launched) {
                      _logger.d('Successfully launched URL in external app');
                      if (mounted) {
                        // Use a separate method to show the snackbar
                        _showExternalAppOpeningSnackbar();
                      }
                    } else {
                      _logger.e(
                          'Failed to launch URL despite canLaunch returning true');
                      if (mounted) {
                        // Use a separate method to show the snackbar
                        _showFailedToOpenUrlSnackbar(url);
                      }
                    }
                  } else {
                    // No app can handle this URL
                    _logger.e('No app found to handle URL: $url');
                    if (mounted) {
                      // Use a separate method to show the snackbar
                      _showNoAppInstalledSnackbar();
                    }
                  }
                } catch (e) {
                  _logger.e('Error launching URL: $e');
                  if (mounted) {
                    // Use a separate method to show the snackbar
                    _showCannotOpenLinkSnackbar();
                  }
                }

                // Cancel loading in the WebView regardless
                return NavigationActionPolicy.CANCEL;
              },
              onReceivedError: (controller, request, error) {
                final refreshController = _pullToRefreshController;
                if (refreshController != null) {
                  refreshController.endRefreshing();
                }

                // Log all errors for debugging
                _logger.e('WebView error: $error');

                setState(() {
                  _isLoading = false;
                });

                // Filter out common non-critical errors
                final errorDesc = error.description.toString().toLowerCase();
                final isCSPError =
                    errorDesc.contains('content security policy') ||
                        errorDesc.contains('csp') ||
                        errorDesc.contains('blocked_by_orb');
                final isResourceError =
                    errorDesc.contains('err_name_not_resolved') ||
                        errorDesc.contains('net::err_');
                final isHttpError =
                    errorDesc.contains('http_response_code_failure') ||
                        errorDesc.contains('status code');

                // Handle HTTP response errors (like website blocking WebView access)
                if (isHttpError) {
                  _showWebsiteBlockedDialog();
                  return;
                }

                // Only show error message for critical errors
                if (!isCSPError &&
                    (error.type != WebResourceErrorType.UNKNOWN ||
                        !isResourceError)) {
                  _showErrorSnackBar(
                      'Failed to load page: ${error.description}');
                }
              },
              onConsoleMessage: (controller, consoleMessage) {
                // Filter out common CSP warnings that clutter the logs
                final message = consoleMessage.message.toLowerCase();
                if (!message.contains('content security policy') &&
                    !message.contains('refused to load') &&
                    !message.contains('csp')) {
                  _logger.d('Console: ${consoleMessage.message}');
                }
              },
              onCreateWindow: (controller, createWindowAction) async {
                // Handle new window requests (like popups)
                final url = createWindowAction.request.url;
                if (url != null) {
                  _logger.d('New window requested: $url');
                  controller.loadUrl(urlRequest: URLRequest(url: url));
                  return true;
                }
                return false;
              },
            ),
          ),
        ],
      ),
    );
  }

  void _refreshPage() {
    if (_webViewController != null) {
      _webViewController!.reload();
    }
  }

  void _confirmOpenInExternalBrowser() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open in External Browser?'),
        content: const Text(
          'You are about to leave the app and open this link in your device\'s web browser. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openInExternalBrowser();
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  /// Opens the current URL in an external browser
  void _openInExternalBrowser() async {
    try {
      if (_currentUrl.isNotEmpty) {
        final uri = WebUri(_currentUrl);
        await ChromeSafariBrowser().open(url: uri);
      }
    } catch (e) {
      _logger.e('Error opening external browser: $e');
      _showErrorSnackBar('Could not open browser');
    }
  }

  /// Shares the current URL using the device's share sheet
  void _shareUrl() async {
    if (_currentUrl.isNotEmpty) {
      final subject =
          _pageTitle.isNotEmpty ? _pageTitle : 'Shared link from Immigru';
      await SharePlus.instance
          .share(ShareParams(text: _currentUrl, subject: subject));
    }
  }

  /// Copies the current URL to the clipboard
  void _copyUrlToClipboard() {
    final url = _webViewController?.getUrl().toString() ?? '';
    if (url.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: url));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link copied to clipboard')),
        );
      }
    }
  }

  /// Show a snackbar indicating that the URL is opening in an external app
  /// This method avoids using BuildContext across async gaps
  void _showExternalAppOpeningSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Opening in external app...'),
      duration: Duration(seconds: 2),
    ));
  }
  
  /// Show a snackbar indicating that the URL failed to open
  /// This method avoids using BuildContext across async gaps
  void _showFailedToOpenUrlSnackbar(String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to open $url')),
    );
  }
  
  /// Show a snackbar indicating that no app is installed to handle the link
  /// This method avoids using BuildContext across async gaps
  void _showNoAppInstalledSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('No app installed to handle this link'),
      action: SnackBarAction(
        label: 'Copy Link',
        onPressed: () => _copyUrlToClipboard(),
      ),
    ));
  }
  
  /// Show a snackbar indicating that the link cannot be opened
  /// This method avoids using BuildContext across async gaps
  void _showCannotOpenLinkSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Cannot open this link'),
      action: SnackBarAction(
        label: 'Copy Link',
        onPressed: () => _copyUrlToClipboard(),
      ),
    ));
  }
  

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Shows a dialog when a website blocks WebView access
  void _showWebsiteBlockedDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Website Access Restricted'),
        content: const Text(
            'This website appears to restrict access from in-app browsers. '
            'Would you like to open it in your device\'s web browser instead?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openInExternalBrowser();
            },
            child: const Text('Open in Browser'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _copyUrlToClipboard();
            },
            child: const Text('Copy Link'),
          ),
        ],
      ),
    );
  }
}
