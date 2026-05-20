import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ambanotes/app/theme/app_theme.dart';

class DrivePreviewWidget extends StatefulWidget {
  final String viewLink;
  final String title;

  const DrivePreviewWidget({
    Key? key,
    required this.viewLink,
    required this.title,
  }) : super(key: key);

  @override
  State<DrivePreviewWidget> createState() => _DrivePreviewWidgetState();
}

class _DrivePreviewWidgetState extends State<DrivePreviewWidget> {
  WebViewController? _webViewController;
  bool _isLoading = true;
  bool _hasError = false;
  late final String _previewUrl;

  @override
  void initState() {
    super.initState();
    _previewUrl = _getPreviewUrl(widget.viewLink);
    
    // Only initialize WebView on Mobile (Android / iOS)
    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (isMobile) {
      _initWebView();
    }
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF9F9F9)) // Matching AppTheme.surface
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            // Ignore minor assets loading error, but handle fatal ones
            if (error.description.contains('ERR_CONNECTION_REFUSED') ||
                error.description.contains('ERR_NAME_NOT_RESOLVED')) {
              if (mounted) {
                setState(() {
                  _hasError = true;
                  _isLoading = false;
                });
              }
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_previewUrl));
  }

  String _getPreviewUrl(String viewLink) {
    final regExp = RegExp(r'/file/d/([^/]+)');
    final match = regExp.firstMatch(viewLink);
    if (match != null && match.groupCount >= 1) {
      final fileId = match.group(1);
      return 'https://drive.google.com/file/d/$fileId/preview';
    }
    // Fallback replacement if ID regex fails
    if (viewLink.contains('/view')) {
      return viewLink.replaceAll('/view', '/preview');
    }
    return viewLink;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    if (!isMobile) {
      return _buildFallbackCard();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    return Stack(
      children: [
        if (_webViewController != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: WebViewWidget(controller: _webViewController!),
            ),
          ),
        if (_isLoading)
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface.withOpacity(0.85),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primary),
                  SizedBox(height: 16),
                  Text(
                    'Memuat pratinjau dokumen...',
                    style: TextStyle(
                      color: AppTheme.outline,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFallbackCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.hardDrive, size: 40, color: Colors.blue),
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppTheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          const Text(
            'Pratinjau Dokumen Google Drive',
            style: TextStyle(
              color: AppTheme.outline,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                await launchUrl(Uri.parse(widget.viewLink), mode: LaunchMode.externalApplication);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal membuka pratinjau: $e')),
                );
              }
            },
            icon: const Icon(LucideIcons.externalLink, size: 16, color: Colors.white),
            label: const Text(
              'Buka di Browser',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.alertTriangle, size: 40, color: Colors.amber),
          const SizedBox(height: 16),
          const Text(
            'Gagal Memuat Pratinjau',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Koneksi internet tidak stabil atau tautan Drive tidak valid.',
            style: TextStyle(color: AppTheme.outline, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
              _webViewController?.loadRequest(Uri.parse(_previewUrl));
            },
            icon: const Icon(LucideIcons.refreshCw, size: 14),
            label: const Text('Coba Lagi'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primary,
              side: const BorderSide(color: AppTheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
