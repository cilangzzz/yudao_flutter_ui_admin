import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:yudao_flutter_ui_admin/api/system/oauth2_client_api.dart';
import 'package:yudao_flutter_ui_admin/models/system/oauth2_client.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

/// OAuth2 客户端管理页面
class OAuth2ClientPage extends ConsumerStatefulWidget {
  const OAuth2ClientPage({super.key});

  @override
  ConsumerState<OAuth2ClientPage> createState() => _OAuth2ClientPageState();
}

class _OAuth2ClientPageState extends ConsumerState<OAuth2ClientPage> {
  final _searchController = TextEditingController();
  int? _selectedStatus;

  List<OAuth2Client> _dataList = [];
  Set<int> _selectedIds = {};
  int _totalCount = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = true;
  String? _error;

  // 授权类型选项
  static const List<Map<String, String>> _grantTypes = [
    {'value': 'password', 'label': '密码模式'},
    {'value': 'authorization_code', 'label': '授权码模式'},
    {'value': 'implicit', 'label': '简化模式'},
    {'value': 'client_credentials', 'label': '客户端模式'},
    {'value': 'refresh_token', 'label': '刷新模式'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(oauth2ClientApiProvider);
      final params = {
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_searchController.text.isNotEmpty) 'name': _searchController.text,
        if (_selectedStatus != null) 'status': _selectedStatus,
      };

      final response = await api.getOAuth2ClientPage(params);
      if (response.isSuccess && response.data != null) {
        setState(() {
          _dataList = response.data!.list;
          _totalCount = response.data!.total;
          _isLoading = false;
          _selectedIds.clear();
        });
      } else {
        setState(() {
          _error = response.msg.isNotEmpty ? response.msg : '加载失败';
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
    setState(() => _selectedStatus = null);
    _currentPage = 1;
    _loadData();
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择要删除的客户端')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除选中的 ${_selectedIds.length} 个客户端吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final api = ref.read(oauth2ClientApiProvider);
        final response = await api.deleteOAuth2ClientList(_selectedIds.toList());

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('删除成功')),
            );
            _loadData();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg.isNotEmpty ? response.msg : '删除失败')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteItem(OAuth2Client item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除客户端 "${item.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && item.id != null) {
      final api = ref.read(oauth2ClientApiProvider);
      final response = await api.deleteOAuth2Client(item.id!);
      if (response.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('删除成功')),
          );
          _loadData();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: ${response.msg}')),
          );
        }
      }
    }
  }

  /// 显示分步表单弹窗
  void _showFormDialog([OAuth2Client? item]) {
    final isEdit = item != null;

    // 表单控制器
    final nameController = TextEditingController(text: item?.name ?? '');
    final clientIdController = TextEditingController(text: item?.clientId ?? '');
    final secretController = TextEditingController(text: item?.secret ?? '');
    final accessTokenValiditySecondsController = TextEditingController(
      text: item?.accessTokenValiditySeconds?.toString() ?? '3600',
    );
    final refreshTokenValiditySecondsController = TextEditingController(
      text: item?.refreshTokenValiditySeconds?.toString() ?? '86400',
    );
    final redirectUrisController = TextEditingController(text: item?.redirectUris?.join(',') ?? '');
    final additionalInformationController = TextEditingController(text: item?.additionalInformation ?? '');

    // 表单状态
    int currentStep = 0;
    List<String> selectedGrantTypes = item?.authorizedGrantTypes ?? ['password'];
    List<String> scopes = item?.scopes ?? [];
    int status = item?.status ?? 0;
    bool autoApprove = item?.autoApprove ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? '编辑OAuth2客户端' : '新增OAuth2客户端'),
          content: SizedBox(
            width: 550,
            height: 480,
            child: Stepper(
              type: StepperType.vertical,
              currentStep: currentStep,
              onStepContinue: () {
                if (currentStep < 2) {
                  setDialogState(() => currentStep++);
                } else {
                  _submitForm(
                    item: item,
                    nameController: nameController,
                    clientIdController: clientIdController,
                    secretController: secretController,
                    accessTokenValiditySecondsController: accessTokenValiditySecondsController,
                    refreshTokenValiditySecondsController: refreshTokenValiditySecondsController,
                    redirectUrisController: redirectUrisController,
                    additionalInformationController: additionalInformationController,
                    selectedGrantTypes: selectedGrantTypes,
                    scopes: scopes,
                    status: status,
                    autoApprove: autoApprove,
                    isEdit: isEdit,
                  );
                }
              },
              onStepCancel: () {
                if (currentStep > 0) {
                  setDialogState(() => currentStep--);
                }
              },
              onStepTapped: (step) {
                setDialogState(() => currentStep = step);
              },
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      if (currentStep < 2)
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          child: const Text('下一步'),
                        ),
                      if (currentStep == 2)
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          child: const Text('提交'),
                        ),
                      if (currentStep > 0)
                        TextButton(
                          onPressed: details.onStepCancel,
                          child: const Text('上一步'),
                        ),
                    ],
                  ),
                );
              },
              steps: [
                // 步骤1：基本信息
                Step(
                  title: const Text('基本信息'),
                  isActive: currentStep >= 0,
                  content: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: '客户端名称 *',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: clientIdController,
                        decoration: const InputDecoration(
                          labelText: '客户端编号 *',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: secretController,
                        decoration: const InputDecoration(
                          labelText: '客户端密钥',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: additionalInformationController,
                        decoration: const InputDecoration(
                          labelText: '附加信息',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                // 步骤2：授权配置
                Step(
                  title: const Text('授权配置'),
                  isActive: currentStep >= 1,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('授权类型', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _grantTypes.map((gt) {
                          final value = gt['value']!;
                          final label = gt['label']!;
                          final isSelected = selectedGrantTypes.contains(value);
                          return FilterChip(
                            label: Text(label),
                            selected: isSelected,
                            onSelected: (selected) {
                              setDialogState(() {
                                if (selected) {
                                  selectedGrantTypes.add(value);
                                } else {
                                  selectedGrantTypes.remove(value);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: redirectUrisController,
                        decoration: const InputDecoration(
                          labelText: '回调地址',
                          hintText: '多个地址用逗号分隔',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: accessTokenValiditySecondsController,
                              decoration: const InputDecoration(
                                labelText: '访问令牌有效期(秒)',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: refreshTokenValiditySecondsController,
                              decoration: const InputDecoration(
                                labelText: '刷新令牌有效期(秒)',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 步骤3：范围和状态
                Step(
                  title: const Text('范围和状态'),
                  isActive: currentStep >= 2,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: TextEditingController(text: scopes.join(',')),
                        decoration: const InputDecoration(
                          labelText: '授权范围',
                          hintText: '多个范围用逗号分隔',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          scopes = value.split(',').where((e) => e.trim().isNotEmpty).toList();
                        },
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('自动授权'),
                        value: autoApprove,
                        onChanged: (value) {
                          setDialogState(() => autoApprove = value);
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: status,
                        decoration: const InputDecoration(
                          labelText: '状态',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('开启')),
                          DropdownMenuItem(value: 1, child: Text('禁用')),
                        ],
                        onChanged: (value) {
                          setDialogState(() => status = value ?? 0);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm({
    OAuth2Client? item,
    required TextEditingController nameController,
    required TextEditingController clientIdController,
    required TextEditingController secretController,
    required TextEditingController accessTokenValiditySecondsController,
    required TextEditingController refreshTokenValiditySecondsController,
    required TextEditingController redirectUrisController,
    required TextEditingController additionalInformationController,
    required List<String> selectedGrantTypes,
    required List<String> scopes,
    required int status,
    required bool autoApprove,
    required bool isEdit,
  }) async {
    if (nameController.text.isEmpty || clientIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写必填项')),
      );
      return;
    }

    if (selectedGrantTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少选择一种授权类型')),
      );
      return;
    }

    final redirectUrisText = redirectUrisController.text.trim();
    final redirectUrisList = redirectUrisText.isNotEmpty
        ? redirectUrisText.split(',').where((e) => e.trim().isNotEmpty).toList()
        : null;

    final data = OAuth2Client(
      id: item?.id,
      name: nameController.text.trim(),
      clientId: clientIdController.text.trim(),
      secret: secretController.text.trim().isNotEmpty ? secretController.text.trim() : null,
      accessTokenValiditySeconds: int.tryParse(accessTokenValiditySecondsController.text) ?? 3600,
      refreshTokenValiditySeconds: int.tryParse(refreshTokenValiditySecondsController.text) ?? 86400,
      redirectUris: redirectUrisList,
      additionalInformation: additionalInformationController.text.trim().isNotEmpty ? additionalInformationController.text.trim() : null,
      authorizedGrantTypes: selectedGrantTypes,
      scopes: scopes.isNotEmpty ? scopes : null,
      autoApprove: autoApprove,
      status: status,
    );

    final api = ref.read(oauth2ClientApiProvider);
    final response = isEdit
        ? await api.updateOAuth2Client(data)
        : await api.createOAuth2Client(data);

    if (mounted) {
      if (response.isSuccess) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEdit ? '更新成功' : '创建成功')),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: ${response.msg}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = DeviceUIMode.isMobile(context);

    return Scaffold(
      body: Column(
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
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: () => _showFormDialog(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;

          if (isMobile) {
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: '客户端名称',
                      prefixIcon: Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(),
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
                const SizedBox(width: 4),
                PopupMenuButton<int>(
                  initialValue: _selectedStatus,
                  onSelected: (value) {
                    setState(() => _selectedStatus = value == -1 ? null : value);
                    _search();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: -1, child: Text('全部状态')),
                    const PopupMenuItem(value: 0, child: Text('开启')),
                    const PopupMenuItem(value: 1, child: Text('禁用')),
                  ],
                  child: const Icon(Icons.filter_list),
                ),
              ],
            );
          }

          return Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              SizedBox(
                width: 180,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: '客户端名称',
                    prefixIcon: Icon(Icons.search, size: 18),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
              SizedBox(
                width: 120,
                child: DropdownButtonFormField<int>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: '状态',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('全部')),
                    DropdownMenuItem(value: 0, child: Text('开启')),
                    DropdownMenuItem(value: 1, child: Text('禁用')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedStatus = value);
                  },
                ),
              ),
              ElevatedButton.icon(
                onPressed: _search,
                icon: const Icon(Icons.search, size: 18),
                label: const Text('搜索'),
              ),
              OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('重置'),
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
            label: const Text('新增客户端'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete, size: 18),
            label: Text('批量删除 (${_selectedIds.length})'),
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
            Text('加载失败: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('重试')),
          ],
        ),
      );
    }

    if (_dataList.isEmpty) {
      return const Center(child: Text('暂无数据'));
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

  Widget _buildClientCard(OAuth2Client item) {
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
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.key,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                        item.clientId,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        overflow: TextOverflow.ellipsis,
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
                    item.status == 0 ? '开启' : '禁用',
                    style: TextStyle(color: item.status == 0 ? Colors.green : Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildMobileInfoRow(Icons.timer, '访问令牌有效期', '${item.accessTokenValiditySeconds ?? 0} 秒'),
            _buildMobileInfoRow(Icons.timer_outlined, '刷新令牌有效期', '${item.refreshTokenValiditySeconds ?? 0} 秒'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showFormDialog(item),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('编辑'),
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
                    label: const Text('删除'),
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
          Text('共 $_totalCount 条'),
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
            Text('加载失败: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('重试')),
          ],
        ),
      );
    }

    if (_dataList.isEmpty) {
      return const Center(child: Text('暂无数据'));
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
              const Text('OAuth2 客户端列表'),
              const Spacer(),
              Text('共 $_totalCount 条'),
            ],
          ),
          const SizedBox(height: 8),
          // 表格
          Expanded(
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 900,
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
                  label: const Text('客户端名称'),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: const Text('客户端编号'),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: const Text('授权类型'),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: const Text('访问令牌有效期'),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: const Text('状态'),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: const Text('创建时间'),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: const Text('操作'),
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
                    DataCell(Text(item.clientId, overflow: TextOverflow.ellipsis)),
                    DataCell(
                      Tooltip(
                        message: item.authorizedGrantTypes?.join(', ') ?? '',
                        child: Text(
                          _formatGrantTypes(item.authorizedGrantTypes),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(Text('${item.accessTokenValiditySeconds ?? 0}秒')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.status == 0 ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.status == 0 ? '开启' : '禁用',
                          style: TextStyle(color: item.status == 0 ? Colors.green : Colors.red, fontSize: 12),
                        ),
                      ),
                    ),
                    DataCell(Text(item.createTime ?? '-')),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => _showFormDialog(item),
                            child: const Text('编辑'),
                          ),
                          TextButton(
                            onPressed: () => _deleteItem(item),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('删除'),
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

  String _formatGrantTypes(List<String>? types) {
    if (types == null || types.isEmpty) return '-';

    final labels = <String>[];
    for (final type in types) {
      final gt = _grantTypes.firstWhere(
        (e) => e['value'] == type.trim(),
        orElse: () => {'value': type.trim(), 'label': type.trim()},
      );
      labels.add(gt['label']!);
    }

    return labels.join(', ');
  }

  Widget _buildDesktopPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          children: [
            const Text('每页: '),
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
        Text('共 $_totalCount 条'),
        const SizedBox(width: 16),
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