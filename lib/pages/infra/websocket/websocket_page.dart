import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/system/user_api.dart';
import '../../../core/constants/app_constants.dart';
import '../../../i18n/i18n.dart';
import '../../../models/system/user.dart' show SimpleUser;

/// WebSocket 消息类型
enum MessageType {
  group,
  single,
  system,
  unknown,
}

/// WebSocket 消息模型
class WebSocketMessage {
  final String text;
  final DateTime time;
  final MessageType type;
  final String? userId;

  WebSocketMessage({
    required this.text,
    required this.time,
    this.type = MessageType.unknown,
    this.userId,
  });
}

/// WebSocket 监控页面
class WebSocketPage extends ConsumerStatefulWidget {
  const WebSocketPage({super.key});

  @override
  ConsumerState<WebSocketPage> createState() => _WebSocketPageState();
}

class _WebSocketPageState extends ConsumerState<WebSocketPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<WebSocketMessage> _messages = [];
  List<SimpleUser> _userList = [];

  bool _isConnected = false;
  bool _isConnecting = false;
  String? _selectedUserId = 'all';
  String? _error;

  // WebSocket 相关
  // 注意: 实际的 WebSocket 连接需要使用 web_socket_channel 或类似包
  // 这里简化实现，展示 UI 结构
  Timer? _heartbeatTimer;

  @override
  void initState() {
    super.initState();
    _loadUserList();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _heartbeatTimer?.cancel();
    _disconnect();
    super.dispose();
  }

  Future<void> _loadUserList() async {
    try {
      final userApi = ref.read(userApiProvider);
      final response = await userApi.getSimpleUserList();
      if (response.isSuccess && response.data != null) {
        setState(() {
          _userList = response.data!;
        });
      }
    } catch (e) {
      // 忽略错误
    }
  }

  void _connect() {
    setState(() {
      _isConnecting = true;
      _error = null;
    });

    // 模拟连接
    // 实际实现需要使用 web_socket_channel
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isConnected = true;
          _isConnecting = false;
        });
        _startHeartbeat();
        _addSystemMessage('WebSocket 连接成功');
      }
    });
  }

  void _disconnect() {
    _heartbeatTimer?.cancel();
    setState(() {
      _isConnected = false;
      _isConnecting = false;
    });
    _addSystemMessage('WebSocket 连接已断开');
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      // 发送心跳
      if (_isConnected) {
        // _channel?.sink.add('ping');
      }
    });
  }

  void _addSystemMessage(String text) {
    setState(() {
      _messages.insert(0, WebSocketMessage(
        text: text,
        time: DateTime.now(),
        type: MessageType.system,
      ));
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.messageCannotBeEmpty)),
      );
      return;
    }

    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.pleaseConnectFirst)),
      );
      return;
    }

    // 构建消息
    final messageContent = jsonEncode({
      'text': text,
      'toUserId': _selectedUserId == 'all' ? null : _selectedUserId,
    });
    final jsonMessage = jsonEncode({
      'type': 'demo-message-send',
      'content': messageContent,
    });

    // 发送消息
    // _channel?.sink.add(jsonMessage);

    // 添加到消息列表
    setState(() {
      _messages.insert(0, WebSocketMessage(
        text: text,
        time: DateTime.now(),
        type: _selectedUserId == 'all' ? MessageType.group : MessageType.single,
      ));
    });

    _messageController.clear();
  }

  Color _getMessageColor(MessageType type) {
    switch (type) {
      case MessageType.group:
        return Colors.green;
      case MessageType.single:
        return Colors.blue;
      case MessageType.system:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getMessageTypeText(MessageType type) {
    switch (type) {
      case MessageType.group:
        return S.current.groupMessage;
      case MessageType.single:
        return S.current.singleMessage;
      case MessageType.system:
        return S.current.systemMessage;
      default:
        return S.current.unknown;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 左侧：连接管理和发送消息
          Expanded(
            flex: 1,
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 连接状态
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isConnected ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          S.current.connectionManagement,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 连接状态显示
                    Row(
                      children: [
                        Text('${S.current.connectionStatus}: '),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _isConnected ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _isConnected ? S.current.connected : S.current.disconnected,
                            style: TextStyle(
                              color: _isConnected ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 服务地址
                    Text(
                      '${S.current.serverAddress}:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${AppConstants.baseUrl.replaceFirst('http', 'ws')}/infra/ws?token=xxx',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 连接/断开按钮
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isConnecting
                            ? null
                            : _isConnected
                                ? _disconnect
                                : _connect,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isConnected ? Colors.red : Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          _isConnecting
                              ? S.current.connecting
                              : _isConnected
                                  ? S.current.disconnect
                                  : S.current.connect,
                        ),
                      ),
                    ),

                    const Divider(height: 32),

                    // 消息发送区域
                    Text(
                      S.current.sendMessage,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),

                    // 接收人选择
                    DropdownButtonFormField<String>(
                      value: _selectedUserId,
                      decoration: InputDecoration(
                        labelText: S.current.selectReceiver,
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'all',
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 12,
                                child: Text('A', style: TextStyle(fontSize: 10)),
                              ),
                              const SizedBox(width: 8),
                              Text(S.current.everyone),
                            ],
                          ),
                        ),
                        ..._userList.map((user) => DropdownMenuItem(
                          value: user.id.toString(),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                child: Text(
                                  (user.nickname?.isNotEmpty == true ? user.nickname![0] : 'U'),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(user.nickname ?? ''),
                            ],
                          ),
                        )),
                      ],
                      onChanged: _isConnected
                          ? (value) => setState(() => _selectedUserId = value)
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // 消息输入
                    TextField(
                      controller: _messageController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: S.current.messageContent,
                        border: const OutlineInputBorder(),
                      ),
                      enabled: _isConnected,
                    ),
                    const SizedBox(height: 16),

                    // 发送按钮
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isConnected ? _sendMessage : null,
                        icon: const Icon(Icons.send),
                        label: Text(S.current.sendMessage),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 右侧：消息记录
          Expanded(
            flex: 1,
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.message),
                        const SizedBox(width: 8),
                        Text(
                          S.current.messageHistory,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (_messages.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_messages.length} ${S.current.messagesCount}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Divider(height: 24),

                    // 消息列表
                    Expanded(
                      child: _messages.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    S.current.noMessages,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final msg = _messages[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: _getMessageColor(msg.type),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _getMessageTypeText(msg.type),
                                              style: TextStyle(
                                                color: _getMessageColor(msg.type),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (msg.userId != null) ...[
                                              const SizedBox(width: 8),
                                              Text(
                                                '${S.current.userId}: ${msg.userId}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                            const Spacer(),
                                            Text(
                                              _formatTime(msg.time),
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(msg.text),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}