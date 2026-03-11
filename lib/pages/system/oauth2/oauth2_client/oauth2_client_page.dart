import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../../api/system/oauth2_client_api.dart';
import '../../../../models/system/oauth2_client.dart';
import '../../../../models/common/api_response.dart';


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
    setState(() {
      _selectedStatus = null;
    });
    _currentPage = 1;
    _loadData();
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择要删除的数据')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除选中的 ${_selectedIds.length} 条数据吗？'),
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
              SnackBar(content: Text('删除失败: ${response.msg}')),
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

  Future<void> _delete(OAuth2Client item) async {
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
      try {
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
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: $e')),
          );
        }
      }
    }
  }

  void _showFormDialog([OAuth2Client? item]) {
    final isEdit = item != null;
    final clientIdController = TextEditingController(text: item?.clientId ?? '');
    final secretController = TextEditingController(text: item?.secret ?? '');
    final nameController = TextEditingController(text: item?.name ?? '');
    final logoController = TextEditingController(text: item?.logo ?? '');
    final descriptionController = TextEditingController(text: item?.description ?? '');
    final accessTokenValidityController = TextEditingController(
      text: (item?.accessTokenValiditySeconds ?? 3600).toString(),
    );
    final refreshTokenValidityController = TextEditingController(
      text: (item?.refreshTokenValiditySeconds ?? 86400).toString(),
    );
    final additionalInfoController = TextEditingController(text: item?.additionalInformation ?? '');
    final redirectUriController = TextEditingController();

    int status = item?.status ?? 0;
    List<String> selectedGrantTypes = item?.authorizedGrantTypes ?? ['password', 'refresh_token'];
    List<String> scopes = item?.scopes ?? [];
    List<String> autoApproveScopes = [];
    List<String> redirectUris = item?.redirectUris ?? [];
    List<String> authorities = item?.authorities ?? [];
    List<String> resourceIds = item?.resourceIds ?? [];
    String newScope = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEdit ? '编辑 OAuth2 客户端' : '新增 OAuth2 客户端'),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 基本信息
                  _buildSectionTitle('基本信息'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: clientIdController,
                          decoration: const InputDecoration(
                            labelText: '客户端编号 *',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: secretController,
                          decoration: const InputDecoration(
                            labelText: '客户端密钥 *',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: '应用名称 *',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: logoController,
                          decoration: const InputDecoration(
                            labelText: '应用图标URL',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: '应用描述',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('状态: '),
                      Radio<int>(
                        value: 0,
                        groupValue: status,
                        onChanged: (value) => setState(() => status = value!),
                      ),
                      const Text('开启'),
                      Radio<int>(
                        value: 1,
                        groupValue: status,
                        onChanged: (value) => setState(() => status = value!),
                      ),
                      const Text('禁用'),
                    ],
                  ),
                  const Divider(height: 24),

                  // 令牌配置
                  _buildSectionTitle('令牌配置'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: accessTokenValidityController,
                          decoration: const InputDecoration(
                            labelText: '访问令牌有效期(秒) *',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: refreshTokenValidityController,
                          decoration: const InputDecoration(
                            labelText: '刷新令牌有效期(秒) *',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // 授权配置
                  _buildSectionTitle('授权配置'),
                  const SizedBox(height: 12),
                  const Text('授权类型 *', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _grantTypes.map((type) {
                      final isSelected = selectedGrantTypes.contains(type['value']);
                      return FilterChip(
                        label: Text(type['label']!),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedGrantTypes.add(type['value']!);
                            } else {
                              selectedGrantTypes.remove(type['value']!);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // 授权范围
                  const Text('授权范围', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: scopes.map((scope) {
                      return Chip(
                        label: Text(scope),
                        onDeleted: () {
                          setState(() {
                            scopes.remove(scope);
                            autoApproveScopes.remove(scope);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: '输入授权范围',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (value) => newScope = value,
                          onSubmitted: (value) {
                            if (value.isNotEmpty && !scopes.contains(value)) {
                              setState(() => scopes.add(value));
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (newScope.isNotEmpty && !scopes.contains(newScope)) {
                            setState(() => scopes.add(newScope));
                          }
                        },
                        child: const Text('添加'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 自动授权范围
                  if (scopes.isNotEmpty) ...[
                    const Text('自动授权范围', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: scopes.map((scope) {
                        final isSelected = autoApproveScopes.contains(scope);
                        return FilterChip(
                          label: Text(scope),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                autoApproveScopes.add(scope);
                              } else {
                                autoApproveScopes.remove(scope);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 重定向URI
                  const Text('可重定向的URI地址 *', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: redirectUris.map((uri) {
                      return Chip(
                        label: Text(uri, style: const TextStyle(fontSize: 12)),
                        onDeleted: () {
                          setState(() => redirectUris.remove(uri));
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: redirectUriController,
                          decoration: const InputDecoration(
                            hintText: '输入重定向URI',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty && !redirectUris.contains(value)) {
                              setState(() => redirectUris.add(value));
                              redirectUriController.clear();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final uri = redirectUriController.text;
                          if (uri.isNotEmpty && !redirectUris.contains(uri)) {
                            setState(() => redirectUris.add(uri));
                            redirectUriController.clear();
                          }
                        },
                        child: const Text('添加'),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // 高级配置
                  _buildSectionTitle('高级配置'),
                  const SizedBox(height: 12),

                  // 权限
                  const Text('权限', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: authorities.map((auth) {
                      return Chip(
                        label: Text(auth),
                        onDeleted: () => setState(() => authorities.remove(auth)),
                      );
                    }).toList(),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: '输入权限',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty && !authorities.contains(value)) {
                              setState(() => authorities.add(value));
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('添加'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 资源ID
                  const Text('资源', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: resourceIds.map((id) {
                      return Chip(
                        label: Text(id),
                        onDeleted: () => setState(() => resourceIds.remove(id)),
                      );
                    }).toList(),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: '输入资源ID',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty && !resourceIds.contains(value)) {
                              setState(() => resourceIds.add(value));
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('添加'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 附加信息
                  TextField(
                    controller: additionalInfoController,
                    decoration: const InputDecoration(
                      labelText: '附加信息(JSON格式)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (clientIdController.text.isEmpty ||
                    secretController.text.isEmpty ||
                    nameController.text.isEmpty) {
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

                if (redirectUris.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请至少添加一个重定向URI')),
                  );
                  return;
                }

                final data = OAuth2Client(
                  id: item?.id,
                  clientId: clientIdController.text,
                  secret: secretController.text,
                  name: nameController.text,
                  logo: logoController.text.isEmpty ? null : logoController.text,
                  description: descriptionController.text.isEmpty ? null : descriptionController.text,
                  status: status,
                  accessTokenValiditySeconds: int.tryParse(accessTokenValidityController.text) ?? 3600,
                  refreshTokenValiditySeconds: int.tryParse(refreshTokenValidityController.text) ?? 86400,
                  authorizedGrantTypes: selectedGrantTypes,
                  scopes: scopes.isEmpty ? null : scopes,
                  redirectUris: redirectUris,
                  authorities: authorities.isEmpty ? null : authorities,
                  resourceIds: resourceIds.isEmpty ? null : resourceIds,
                  additionalInformation: additionalInfoController.text.isEmpty ? null : additionalInfoController.text,
                );

                try {
                  final api = ref.read(oauth2ClientApiProvider);
                  ApiResponse<void> response;

                  if (isEdit) {
                    response = await api.updateOAuth2Client(data);
                  } else {
                    response = await api.createOAuth2Client(data);
                  }

                  if (response.isSuccess) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isEdit ? '更新成功' : '创建成功')),
                      );
                      _loadData();
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('操作失败: ${response.msg}')),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('操作失败: $e')),
                    );
                  }
                }
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Scaffold(
      body: Column(
        children: [
          _buildSearchBar(context),
          const Divider(height: 1),
          if (!isMobile) _buildToolbar(context),
          if (!isMobile) const Divider(height: 1),
          Expanded(
            child: isMobile ? _buildMobileList(context) : _buildDataTable(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        icon: const Icon(Icons.add),
        label: const Text('新增客户端'),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '应用名称',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 150,
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
                _search();
              },
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _search,
            icon: const Icon(Icons.search),
            label: const Text('搜索'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
            label: const Text('重置'),
          ),
        ],
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
            icon: const Icon(Icons.add),
            label: const Text('新增'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete),
            label: const Text('批量删除'),
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
              minWidth: 1000,
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
              columns: const [
                DataColumn2(label: Text('客户端编号'), size: ColumnSize.M),
                DataColumn2(label: Text('客户端密钥'), size: ColumnSize.M),
                DataColumn2(label: Text('应用名称'), size: ColumnSize.M),
                DataColumn2(label: Text('应用图标'), size: ColumnSize.S),
                DataColumn2(label: Text('状态'), size: ColumnSize.S),
                DataColumn2(label: Text('访问令牌有效期'), size: ColumnSize.M),
                DataColumn2(label: Text('刷新令牌有效期'), size: ColumnSize.M),
                DataColumn2(label: Text('授权类型'), size: ColumnSize.L),
                DataColumn2(label: Text('创建时间'), size: ColumnSize.L),
                DataColumn2(label: Text('操作'), size: ColumnSize.M),
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
                    DataCell(Text(item.clientId)),
                    DataCell(Text(item.secret ?? '-')),
                    DataCell(Text(item.name)),
                    DataCell(
                      item.logo != null && item.logo!.isNotEmpty
                          ? Image.network(
                              item.logo!,
                              width: 32,
                              height: 32,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 24),
                            )
                          : const Icon(Icons.image_not_supported, size: 24),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.status == 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.status == 0 ? '开启' : '禁用',
                          style: TextStyle(
                            color: item.status == 0 ? Colors.green : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text('${item.accessTokenValiditySeconds ?? 0} 秒')),
                    DataCell(Text('${item.refreshTokenValiditySeconds ?? 0} 秒')),
                    DataCell(
                      Tooltip(
                        message: item.authorizedGrantTypes?.join(', ') ?? '-',
                        child: Text(
                          item.authorizedGrantTypes?.take(2).join(', ') ?? '-',
                          overflow: TextOverflow.ellipsis,
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
                            onPressed: () => _delete(item),
                            child: const Text('删除', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          // 分页
          const SizedBox(height: 8),
          _buildPagination(),
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
        Container(
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
        ),
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
                  child: item.logo != null && item.logo!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.logo!,
                            errorBuilder: (_, __, ___) => const Icon(Icons.apps),
                          ),
                        )
                      : const Icon(Icons.apps),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(item.clientId, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.status == 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.status == 0 ? '开启' : '禁用',
                    style: TextStyle(
                      color: item.status == 0 ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.timer, '访问令牌有效期', '${item.accessTokenValiditySeconds ?? 0} 秒'),
            _buildInfoRow(Icons.timer_outlined, '刷新令牌有效期', '${item.refreshTokenValiditySeconds ?? 0} 秒'),
            _buildInfoRow(Icons.vpn_key, '授权类型', item.authorizedGrantTypes?.join(', ') ?? '-'),
            _buildInfoRow(Icons.access_time, '创建时间', item.createTime ?? '-'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  onPressed: () => _showFormDialog(item),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('编辑'),
                ),
                TextButton.icon(
                  onPressed: () => _delete(item),
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  label: const Text('删除', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildPagination() {
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