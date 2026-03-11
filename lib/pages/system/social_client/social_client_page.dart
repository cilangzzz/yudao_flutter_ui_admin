import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:yudao_flutter_ui_admin/api/system/social_client_api.dart';
import 'package:yudao_flutter_ui_admin/models/system/social_client.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

/// 社交客户端管理页面
class SocialClientPage extends ConsumerStatefulWidget {
  const SocialClientPage({super.key});

  @override
  ConsumerState<SocialClientPage> createState() => _SocialClientPageState();
}

class _SocialClientPageState extends ConsumerState<SocialClientPage> {
  final _searchController = TextEditingController();
  final _clientIdController = TextEditingController();
  int? _selectedStatus;
  int? _selectedSocialType;
  int? _selectedUserType;

  List<SocialClient> _dataList = [];
  Set<int> _selectedIds = {};
  int _totalCount = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = true;
  String? _error;

  // 社交平台类型
  static const Map<int, String> _socialTypes = {
    1: '钉钉',
    2: '企业微信',
    3: '微信',
    4: 'QQ',
    5: '微博',
    6: '微信小程序',
    10: '微信开放平台',
    20: 'QQ小程序',
    30: '支付宝小程序',
    40: '抖音',
  };

  // 用户类型
  static const Map<int, String> _userTypes = {
    1: '管理员',
    2: '会员',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _clientIdController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(socialClientApiProvider);
      final params = <String, dynamic>{
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_searchController.text.isNotEmpty) 'name': _searchController.text,
        if (_clientIdController.text.isNotEmpty) 'clientId': _clientIdController.text,
        if (_selectedStatus != null) 'status': _selectedStatus,
        if (_selectedSocialType != null) 'socialType': _selectedSocialType,
        if (_selectedUserType != null) 'userType': _selectedUserType,
      };
      final response = await api.getSocialClientPage(params);
      if (response.isSuccess && response.data != null) {
        setState(() {
          _dataList = response.data!.list;
          _totalCount = response.data!.total;
          _isLoading = false;
          _selectedIds.clear();
        });
      } else {
        setState(() {
          _error = response.msg.isNotEmpty ? response.msg : S.current.loadFailed;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _search() {
    _currentPage = 1;
    _loadData();
  }

  void _reset() {
    _searchController.clear();
    _clientIdController.clear();
    setState(() {
      _selectedStatus = null;
      _selectedSocialType = null;
      _selectedUserType = null;
    });
    _currentPage = 1;
    _loadData();
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.pleaseSelectData)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text('${S.current.confirmDeleteSelected} (${_selectedIds.length})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.current.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(S.current.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final api = ref.read(socialClientApiProvider);
        final response = await api.deleteSocialClientList(_selectedIds.toList());

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.current.deleteSuccess)),
            );
            _loadData();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg.isNotEmpty ? response.msg : S.current.deleteFailed)),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${S.current.deleteFailed}: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteItem(SocialClient item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.confirmDelete),
        content: Text('${S.current.confirmDelete} "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.current.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(S.current.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && item.id != null) {
      final api = ref.read(socialClientApiProvider);
      final response = await api.deleteSocialClient(item.id!);
      if (response.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.current.deleteSuccess)),
          );
          _loadData();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${S.current.deleteFailed}: ${response.msg}')),
          );
        }
      }
    }
  }

  void _showFormDialog([SocialClient? item]) {
    final isEdit = item != null;
    final nameController = TextEditingController(text: item?.name ?? '');
    final clientIdController = TextEditingController(text: item?.clientId ?? '');
    final clientSecretController = TextEditingController(text: item?.clientSecret ?? '');
    final agentIdController = TextEditingController(text: item?.agentId ?? '');
    final publicKeyController = TextEditingController(text: item?.publicKey ?? '');
    int socialType = item?.socialType ?? 1;
    int userType = item?.userType ?? 1;
    int status = item?.status ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEdit ? S.current.editSocialClient : S.current.addSocialClient),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: '${S.current.appName} *',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: socialType,
                    decoration: InputDecoration(
                      labelText: '${S.current.socialPlatform} *',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _socialTypes.entries
                        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (value) => setState(() => socialType = value ?? 1),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: userType,
                    decoration: InputDecoration(
                      labelText: '${S.current.userType} *',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _userTypes.entries
                        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (value) => setState(() => userType = value ?? 1),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: clientIdController,
                    decoration: InputDecoration(
                      labelText: '${S.current.clientId} *',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: clientSecretController,
                    decoration: InputDecoration(
                      labelText: S.current.clientSecret,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // agentId 仅企业微信时显示
                  if (socialType == 2)
                    Column(
                      children: [
                        TextField(
                          controller: agentIdController,
                          decoration: InputDecoration(
                            labelText: S.current.agentId,
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  // publicKey 仅抖音时显示
                  if (socialType == 40)
                    Column(
                      children: [
                        TextField(
                          controller: publicKeyController,
                          decoration: InputDecoration(
                            labelText: S.current.publicKey,
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  DropdownButtonFormField<int>(
                    value: status,
                    decoration: InputDecoration(
                      labelText: S.current.status,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      DropdownMenuItem(value: 0, child: Text(S.current.enabled)),
                      DropdownMenuItem(value: 1, child: Text(S.current.disabled)),
                    ],
                    onChanged: (value) => setState(() => status = value ?? 0),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.current.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || clientIdController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.current.pleaseFillRequired)),
                  );
                  return;
                }

                final data = SocialClient(
                  id: item?.id,
                  name: nameController.text,
                  socialType: socialType,
                  userType: userType,
                  clientId: clientIdController.text,
                  clientSecret: clientSecretController.text.isEmpty ? null : clientSecretController.text,
                  agentId: agentIdController.text.isEmpty ? null : agentIdController.text,
                  publicKey: publicKeyController.text.isEmpty ? null : publicKeyController.text,
                  status: status,
                );

                final api = ref.read(socialClientApiProvider);
                final response = isEdit
                    ? await api.updateSocialClient(data)
                    : await api.createSocialClient(data);

                if (response.isSuccess) {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEdit ? S.current.updateSuccess : S.current.createSuccess)),
                    );
                    _loadData();
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${S.current.operationFailed}: ${response.msg}')),
                    );
                  }
                }
              },
              child: Text(S.current.confirm),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DeviceUIMode.layoutBuilder(
        builder: (context, uiMode) {
          final isMobile = uiMode == UIMode.mobile;
          return Column(
            children: [
              _buildSearchBar(context),
              const Divider(height: 1),
              if (!isMobile) _buildToolbar(context),
              if (!isMobile) const Divider(height: 1),
              Expanded(
                child: DeviceUIMode.builder(
                  context,
                  mobile: (context) => _buildMobileList(context),
                  desktop: (context) => _buildDataTable(context),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: DeviceUIMode.select(
        context,
        mobile: () => FloatingActionButton(
          onPressed: () => _showFormDialog(),
          child: const Icon(Icons.add),
        ),
        desktop: () => null,
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;

          if (isMobile) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: S.current.appName,
                          prefixIcon: const Icon(Icons.search, size: 20),
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        onSubmitted: (_) => _search(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _search,
                      icon: const Icon(Icons.search),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedSocialType,
                        decoration: InputDecoration(
                          hintText: S.current.socialPlatform,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          DropdownMenuItem(value: null, child: Text(S.current.all)),
                          ..._socialTypes.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedSocialType = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          hintText: S.current.status,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          DropdownMenuItem(value: null, child: Text(S.current.all)),
                          DropdownMenuItem(value: 0, child: Text(S.current.enabled)),
                          DropdownMenuItem(value: 1, child: Text(S.current.disabled)),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedStatus = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(S.current.reset),
                    ),
                  ],
                ),
              ],
            );
          }

          return Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              SizedBox(
                width: 160,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: S.current.appName,
                    prefixIcon: const Icon(Icons.search, size: 18),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
              SizedBox(
                width: 160,
                child: TextField(
                  controller: _clientIdController,
                  decoration: InputDecoration(
                    hintText: S.current.clientId,
                    prefixIcon: const Icon(Icons.vpn_key, size: 18),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
              SizedBox(
                width: 130,
                child: DropdownButtonFormField<int>(
                  value: _selectedSocialType,
                  decoration: InputDecoration(
                    labelText: S.current.socialPlatform,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    DropdownMenuItem(value: null, child: Text(S.current.all)),
                    ..._socialTypes.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedSocialType = value);
                  },
                ),
              ),
              SizedBox(
                width: 100,
                child: DropdownButtonFormField<int>(
                  value: _selectedUserType,
                  decoration: InputDecoration(
                    labelText: S.current.userType,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    DropdownMenuItem(value: null, child: Text(S.current.all)),
                    ..._userTypes.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedUserType = value);
                  },
                ),
              ),
              SizedBox(
                width: 100,
                child: DropdownButtonFormField<int>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: S.current.status,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    DropdownMenuItem(value: null, child: Text(S.current.all)),
                    DropdownMenuItem(value: 0, child: Text(S.current.enabled)),
                    DropdownMenuItem(value: 1, child: Text(S.current.disabled)),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedStatus = value);
                  },
                ),
              ),
              ElevatedButton.icon(
                onPressed: _search,
                icon: const Icon(Icons.search, size: 18),
                label: Text(S.current.search),
              ),
              OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(S.current.reset),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: () => _showFormDialog(),
            icon: const Icon(Icons.add, size: 18),
            label: Text(S.current.addSocialClient),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete, size: 18),
            label: Text(S.current.deleteBatch),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${S.current.loadFailed}: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: Text(S.current.retry)),
          ],
        ),
      );
    }

    if (_dataList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _dataList.length,
              itemBuilder: (context, index) => _buildClientCard(_dataList[index]),
            ),
          ),
        ),
        _buildMobilePagination(),
      ],
    );
  }

  Widget _buildClientCard(SocialClient item) {
    final socialColor = _getSocialColor(item.socialType);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: socialColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getSocialIcon(item.socialType),
                    color: socialColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _socialTypes[item.socialType] ?? '-',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.status == 0 ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.status == 0 ? S.current.enabled : S.current.disabled,
                    style: TextStyle(color: item.status == 0 ? Colors.green : Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildMobileInfoRow(Icons.person, S.current.userType, _userTypes[item.userType] ?? '-'),
            _buildMobileInfoRow(Icons.vpn_key, S.current.clientId, item.clientId),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showFormDialog(item),
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text(S.current.edit),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _deleteItem(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.delete, size: 18),
                    label: Text(S.current.delete),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSocialIcon(int? socialType) {
    switch (socialType) {
      case 1:
        return Icons.chat; // 钉钉
      case 2:
        return Icons.business; // 企业微信
      case 3:
        return Icons.chat_bubble; // 微信
      case 4:
        return Icons.message; // QQ
      case 5:
        return Icons.public; // 微博
      case 40:
        return Icons.video_library; // 抖音
      default:
        return Icons.share;
    }
  }

  Color _getSocialColor(int? socialType) {
    switch (socialType) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.indigo;
      case 3:
        return Colors.green;
      case 4:
        return Colors.lightBlue;
      case 5:
        return Colors.orange;
      case 40:
        return Colors.black;
      default:
        return Colors.grey;
    }
  }

  Widget _buildMobilePagination() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${S.current.total}: $_totalCount'),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 1
                    ? () {
                        setState(() => _currentPage--);
                        _loadData();
                      }
                    : null,
              ),
              Text('$_currentPage / ${(_totalCount / _pageSize).ceil()}'),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentPage * _pageSize < _totalCount
                    ? () {
                        setState(() => _currentPage++);
                        _loadData();
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${S.current.loadFailed}: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: Text(S.current.retry)),
          ],
        ),
      );
    }

    if (_dataList.isEmpty) {
      return Center(child: Text(S.current.noData));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 表头
          Row(
            children: [
              Checkbox(
                value: _selectedIds.length == _dataList.length && _dataList.isNotEmpty,
                tristate: true,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedIds = _dataList.where((e) => e.id != null).map((e) => e.id!).toSet();
                    } else {
                      _selectedIds.clear();
                    }
                  });
                },
              ),
              Text(S.current.socialClientList),
              const Spacer(),
              Text('${S.current.total}: $_totalCount'),
            ],
          ),
          const SizedBox(height: 8),
          // 表格
          Expanded(
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 800,
              smRatio: 0.75,
              lmRatio: 1.5,
              headingRowColor: WidgetStateProperty.resolveWith(
                (states) => Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              headingTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              dataRowColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3);
                }
                return null;
              }),
              columns: [
                DataColumn2(
                  label: Text('ID'),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.appName),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.socialPlatform),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(S.current.userType),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.clientId),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.status),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(S.current.createTime),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(S.current.operation),
                  size: ColumnSize.M,
                ),
              ],
              rows: _dataList.map((item) {
                final isSelected = item.id != null && _selectedIds.contains(item.id);
                return DataRow2(
                  selected: isSelected,
                  onSelectChanged: (selected) {
                    if (item.id != null) {
                      setState(() {
                        if (selected == true) {
                          _selectedIds.add(item.id!);
                        } else {
                          _selectedIds.remove(item.id!);
                        }
                      });
                    }
                  },
                  cells: [
                    DataCell(Text(item.id?.toString() ?? '-')),
                    DataCell(Text(item.name, overflow: TextOverflow.ellipsis)),
                    DataCell(Text(_socialTypes[item.socialType] ?? '-')),
                    DataCell(Text(_userTypes[item.userType] ?? '-')),
                    DataCell(Text(item.clientId, overflow: TextOverflow.ellipsis)),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.status == 0 ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.status == 0 ? S.current.enabled : S.current.disabled,
                          style: TextStyle(color: item.status == 0 ? Colors.green : Colors.red, fontSize: 12),
                        ),
                      ),
                    ),
                    DataCell(Text(item.createTime?.toString().substring(0, 19) ?? '-')),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => _showFormDialog(item),
                            child: Text(S.current.edit),
                          ),
                          TextButton(
                            onPressed: () => _deleteItem(item),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: Text(S.current.delete),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          // 分页控件
          const SizedBox(height: 8),
          _buildDesktopPagination(),
        ],
      ),
    );
  }

  Widget _buildDesktopPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          children: [
            Text('${S.current.pageSize}: '),
            DropdownButton<int>(
              value: _pageSize,
              items: [10, 20, 50, 100].map((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text('$value'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _pageSize = value;
                    _currentPage = 1;
                  });
                  _loadData();
                }
              },
            ),
          ],
        ),
        const SizedBox(width: 24),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _currentPage > 1
                  ? () {
                      setState(() => _currentPage--);
                      _loadData();
                    }
                  : null,
            ),
            Text('$_currentPage / ${(_totalCount / _pageSize).ceil()}'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _currentPage * _pageSize < _totalCount
                  ? () {
                      setState(() => _currentPage++);
                      _loadData();
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}