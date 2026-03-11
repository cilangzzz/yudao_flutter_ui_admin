import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../i18n/i18n.dart';

/// iframe 占位页面组件
/// 用于显示需要嵌入外部网页的监控页面
class IframePlaceholderPage extends StatelessWidget {
  final String title;
  final String configKey;
  final String defaultUrl;
  final String? description;
  final String? docUrl;
  final Future<String?> Function()? loadUrl;

  const IframePlaceholderPage({
    super.key,
    required this.title,
    required this.configKey,
    required this.defaultUrl,
    this.description,
    this.docUrl,
    this.loadUrl,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: loadUrl?.call(),
      builder: (context, snapshot) {
        final url = snapshot.data ?? defaultUrl;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Scaffold(
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    padding: const EdgeInsets.all(24),
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.open_in_browser,
                              size: 64,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              title,
                              style: Theme.of(context).textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            if (description != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                description!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      url,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy, size: 20),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: url));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(S.current.copiedToClipboard),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    tooltip: S.current.copy,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // 在实际应用中，这里可以打开外部浏览器
                                    // 或者使用 url_launcher 包
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('请在浏览器中打开: $url'),
                                        action: SnackBarAction(
                                          label: S.current.copy,
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(text: url));
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.open_in_new),
                                  label: Text(S.current.view),
                                ),
                                if (docUrl != null)
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: docUrl!));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('文档链接已复制'),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.help_outline),
                                    label: const Text('查看文档'),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '配置键: $configKey',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[500],
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}