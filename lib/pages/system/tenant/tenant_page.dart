import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:yudao_flutter_ui_admin/api/system/tenant_api.dart';
import 'package:yudao_flutter_ui_admin/api/system/tenant_package_api.dart';
import 'package:yudao_flutter_ui_admin/models/system/tenant.dart';
import 'package:yudao_flutter_ui_admin/models/system/tenant_package.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';
import 'package:yudao_flutter_ui_admin/utils/device_ui_mode.dart';

/// 租户管理页面
class TenantPage extends ConsumerStatefulWidget {
  const TenantPage({super.key});

  @override
  ConsumerState<TenantPage> createState() => _TenantPageState();
}

class _TenantPageState extends ConsumerState<TenantPage> {
  // 搜索控制器
  final _nameController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactMobileController = TextEditingController();
  DateTimeRange? _createTimeRange;
  int? _selectedStatus;

  // 数据状态
  List<Tenant> _dataList = [];
  List<TenantPackage> _packageList = [];
  Set<int> _selectedIds = {};
  int _totalCount = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPackageList();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactNameController.dispose();
    _contactMobileController.dispose();
    super.dispose();
  }

  /// 加载租户套餐列表
  Future<void> _loadPackageList() async {
    final api = ref.read(tenantPackageApiProvider);
    final response = await api.getTenantPackageSimpleList();
    if (response.isSuccess && response.data != null) {
      setState(() => _packageList = response.data!);
    }
  }

  /// 加载租户数据
  Future<void> _loadData() async {
    if (_isLoading && _dataList.isNotEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(tenantApiProvider);
      final params = <String, dynamic>{
        'pageNo': _currentPage,
        'pageSize': _pageSize,
        if (_nameController.text.isNotEmpty) 'name': _nameController.text,
        if (_contactNameController.text.isNotEmpty) 'contactName': _contactNameController.text,
        if (_contactMobileController.text.isNotEmpty) 'contactMobile': _contactMobileController.text,
        if (_selectedStatus != null) 'status': _selectedStatus,
        if (_createTimeRange != null) ...{
          'createTime': [
            _createTimeRange!.start.millisecondsSinceEpoch,
            _createTimeRange!.end.millisecondsSinceEpoch,
          ],
        },
      };

      final response = await api.getTenantPage(params);
      if (response.isSuccess && response.data != null) {
        setState(() {
          _dataList = response.data!.list;
          _totalCount = response.data!.total;
          _selectedIds.clear();
        });
      } else {
        setState(() => _error = response.msg);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 重置搜索条件
  void _resetSearch() {
    _nameController.clear();
    _contactNameController.clear();
    _contactMobileController.clear();
    setState(() {
      _selectedStatus = null;
      _createTimeRange = null;
      _currentPage = 1;
    });
    _loadData();
  }

  /// 删除单个租户
  Future<void> _deleteTenant(Tenant tenant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除租户 "${tenant.name}" 吗？'),
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

    if (confirmed == true && tenant.id != null) {
      final api = ref.read(tenantApiProvider);
      final response = await api.deleteTenant(tenant.id!);
      if (mounted) {
        if (response.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('删除成功')),
          );
          _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: ${response.msg}')),
          );
        }
      }
    }
  }

  /// 批量删除租户
  Future<void> _deleteTenantBatch() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择要删除的租户')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认批量删除'),
        content: Text('确定要删除选中的 ${_selectedIds.length} 个租户吗？'),
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
      final api = ref.read(tenantApiProvider);
      final response = await api.deleteTenantList(_selectedIds.toList());
      if (mounted) {
        if (response.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('批量删除成功')),
          );
          _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('批量删除失败: ${response.msg}')),
          );
        }
      }
    }
  }

  /// 显示表单弹窗
  void _showFormDialog([Tenant? tenant]) {
    final isEdit = tenant != null;
    final formKey = GlobalKey<FormState>();

    // 表单控制器
    final nameController = TextEditingController(text: tenant?.name ?? '');
    final contactNameController = TextEditingController(text: tenant?.contactName ?? '');
    final contactMobileController = TextEditingController(text: tenant?.contactMobile ?? '');
    final accountCountController = TextEditingController(text: tenant?.accountCount?.toString() ?? '');
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    // 表单状态
    int? packageId = tenant?.packageId;
    int status = tenant?.status ?? 0;
    DateTime? expireTime = tenant?.expireTime != null
        ? DateTime.tryParse(tenant!.expireTime!)
        : null;
    List<String> websites = tenant?.websites ?? [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? '编辑租户' : '新增租户'),
          content: SizedBox(
            width: 550,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 租户名称
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: '租户名称 *',
                        hintText: '请输入租户名称',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入租户名称';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // 租户套餐
                    DropdownButtonFormField<int>(
                      value: packageId,
                      decoration: const InputDecoration(
                        labelText: '租户套餐 *',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      hint: const Text('请选择租户套餐'),
                      items: _packageList
                          .map((e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(e.name, overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() => packageId = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return '请选择租户套餐';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // 联系人
                    TextFormField(
                      controller: contactNameController,
                      decoration: const InputDecoration(
                        labelText: '联系人 *',
                        hintText: '请输入联系人',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入联系人';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // 联系手机
                    TextFormField(
                      controller: contactMobileController,
                      decoration: const InputDecoration(
                        labelText: '联系手机',
                        hintText: '请输入联系手机',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),

                    // 新增时显示用户名和密码
                    if (!isEdit) ...[
                      TextFormField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: '用户名称 *',
                          hintText: '请输入用户名称',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: (value) {
                          if (!isEdit && (value == null || value.trim().isEmpty)) {
                            return '请输入用户名称';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: '用户密码 *',
                          hintText: '请输入用户密码',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (!isEdit && (value == null || value.trim().isEmpty)) {
                            return '请输入用户密码';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                    ],

                    // 账号额度
                    TextFormField(
                      controller: accountCountController,
                      decoration: const InputDecoration(
                        labelText: '账号额度',
                        hintText: '请输入账号额度',
                        border: OutlineInputBorder(),
                        suffixText: '个',
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),

                    // 过期时间
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: expireTime ?? DateTime.now().add(const Duration(days: 365)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 3650)),
                        );
                        if (date != null) {
                          setDialogState(() => expireTime = date);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '过期时间',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today, size: 18),
                          isDense: true,
                        ),
                        child: Text(
                          expireTime != null
                              ? '${expireTime!.year}-${expireTime!.month.toString().padLeft(2, '0')}-${expireTime!.day.toString().padLeft(2, '0')}'
                              : '请选择过期时间',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 绑定域名
                    TextFormField(
                      initialValue: websites.join('\n'),
                      decoration: const InputDecoration(
                        labelText: '绑定域名',
                        hintText: '每行输入一个域名',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                        isDense: true,
                      ),
                      maxLines: 2,
                      onChanged: (value) {
                        websites = value
                            .split('\n')
                            .where((e) => e.trim().isNotEmpty)
                            .toList();
                      },
                    ),
                    const SizedBox(height: 12),

                    // 租户状态
                    DropdownButtonFormField<int>(
                      value: status,
                      decoration: const InputDecoration(
                        labelText: '租户状态',
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
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                if (packageId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请选择租户套餐')),
                  );
                  return;
                }

                final data = Tenant(
                  id: tenant?.id,
                  name: nameController.text.trim(),
                  packageId: packageId,
                  contactName: contactNameController.text.trim(),
                  contactMobile: contactMobileController.text.trim().isNotEmpty
                      ? contactMobileController.text.trim()
                      : null,
                  accountCount: int.tryParse(accountCountController.text),
                  expireTime: expireTime != null
                      ? '${expireTime!.year}-${expireTime!.month.toString().padLeft(2, '0')}-${expireTime!.day.toString().padLeft(2, '0')}'
                      : null,
                  websites: websites.isNotEmpty ? websites : null,
                  status: status,
                );

                final api = ref.read(tenantApiProvider);
                final response = isEdit
                    ? await api.updateTenant(data)
                    : await api.createTenant(data);

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
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取套餐名称
  String _getPackageName(int? packageId) {
    if (packageId == null) return '-';
    if (packageId == 0) return '系统租户';
    final package = _packageList.where((e) => e.id == packageId).firstOrNull;
    return package?.name ?? '-';
  }

  /// 构建状态标签
  Widget _buildStatusBadge(int? status) {
    final isOpen = status == 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isOpen ? '开启' : '禁用',
        style: TextStyle(
          color: isOpen ? Colors.green : Colors.red,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isMobile = DeviceUIMode.isMobile(context);

    return Scaffold(
      body: Column(
        children: [
          // 搜索栏
          _buildSearchBar(s),
          const Divider(height: 1),

          // 工具栏
          if (!isMobile) _buildToolbar(s),

          // 数据表格
          Expanded(
            child: DeviceUIMode.builder(
              context,
              mobile: (context) => _buildMobileList(s),
              desktop: (context) => _buildDataTable(),
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

  Widget _buildSearchBar(S s) {
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
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: '租户名',
                          prefixIcon: Icon(Icons.search, size: 20),
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        onSubmitted: (_) => _loadData(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _loadData,
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
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          hintText: '状态',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: _resetSearch,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('重置'),
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
              // 租户名
              SizedBox(
                width: 180,
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '租户名',
                    hintText: '请输入租户名',
                    prefixIcon: Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onSubmitted: (_) => _loadData(),
                ),
              ),

              // 联系人
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _contactNameController,
                  decoration: const InputDecoration(
                    labelText: '联系人',
                    hintText: '请输入联系人',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onSubmitted: (_) => _loadData(),
                ),
              ),

              // 联系手机
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _contactMobileController,
                  decoration: const InputDecoration(
                    labelText: '联系手机',
                    hintText: '请输入联系手机',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onSubmitted: (_) => _loadData(),
                ),
              ),

              // 状态
              SizedBox(
                width: 120,
                child: DropdownButtonFormField<int>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: '状态',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

              // 创建时间
              SizedBox(
                width: 240,
                child: InkWell(
                  onTap: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      initialDateRange: _createTimeRange,
                    );
                    if (range != null) {
                      setState(() => _createTimeRange = range);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: '创建时间',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      suffixIcon: Icon(Icons.calendar_today, size: 18),
                    ),
                    child: Text(
                      _createTimeRange != null
                          ? '${_createTimeRange!.start.toString().substring(0, 10)} ~ ${_createTimeRange!.end.toString().substring(0, 10)}'
                          : '请选择时间范围',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: _createTimeRange != null ? null : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),

              // 搜索按钮
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.search, size: 18),
                label: Text(s.search),
              ),

              // 重置按钮
              OutlinedButton.icon(
                onPressed: _resetSearch,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(s.reset),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildToolbar(S s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // 新增按钮
          ElevatedButton.icon(
            onPressed: () => _showFormDialog(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('新增租户'),
          ),
          // 批量删除按钮
          ElevatedButton.icon(
            onPressed: _selectedIds.isEmpty ? null : _deleteTenantBatch,
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedIds.isEmpty ? null : Colors.red,
              foregroundColor: _selectedIds.isEmpty ? null : Colors.white,
            ),
            icon: const Icon(Icons.delete, size: 18),
            label: Text('批量删除 (${_selectedIds.length})'),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(S s) {
    if (_isLoading && _dataList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('重试')),
          ],
        ),
      );
    }

    if (_dataList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('暂无数据', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _dataList.length,
              itemBuilder: (context, index) => _buildTenantCard(_dataList[index]),
            ),
          ),
        ),
        _buildMobilePagination(),
      ],
    );
  }

  Widget _buildTenantCard(Tenant tenant) {
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
                    Icons.business,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tenant.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'ID: ${tenant.id ?? '-'}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(tenant.status),
              ],
            ),
            const Divider(height: 24),
            _buildMobileInfoRow(Icons.person, '联系人', tenant.contactName ?? '-'),
            _buildMobileInfoRow(Icons.phone, '联系电话', tenant.contactMobile ?? '-'),
            _buildMobileInfoRow(Icons.inventory_2, '套餐', _getPackageName(tenant.packageId)),
            _buildMobileInfoRow(Icons.event, '过期时间', tenant.expireTime ?? '-'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showFormDialog(tenant),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('编辑'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _deleteTenant(tenant),
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

  Widget _buildDataTable() {
    if (_isLoading && _dataList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('重试')),
          ],
        ),
      );
    }

    return Column(
      children: [
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
            columns: [
              DataColumn2(
                label: Checkbox(
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
                size: ColumnSize.S,
              ),
              const DataColumn2(label: Text('租户编号'), size: ColumnSize.S),
              const DataColumn2(label: Text('租户名')),
              const DataColumn2(label: Text('租户套餐')),
              const DataColumn2(label: Text('联系人'), size: ColumnSize.S),
              const DataColumn2(label: Text('联系手机'), size: ColumnSize.S),
              const DataColumn2(label: Text('账号额度'), size: ColumnSize.S),
              const DataColumn2(label: Text('过期时间')),
              const DataColumn2(label: Text('状态'), size: ColumnSize.S),
              const DataColumn2(label: Text('创建时间')),
              const DataColumn2(label: Text('操作'), size: ColumnSize.M),
            ],
            rows: _dataList.map((tenant) {
              return DataRow2(
                selected: tenant.id != null && _selectedIds.contains(tenant.id),
                onSelectChanged: tenant.id != null
                    ? (selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedIds.add(tenant.id!);
                          } else {
                            _selectedIds.remove(tenant.id!);
                          }
                        });
                      }
                    : null,
                cells: [
                  DataCell(Checkbox(
                    value: tenant.id != null && _selectedIds.contains(tenant.id),
                    onChanged: tenant.id != null
                        ? (value) {
                            setState(() {
                              if (value == true) {
                                _selectedIds.add(tenant.id!);
                              } else {
                                _selectedIds.remove(tenant.id!);
                              }
                            });
                          }
                        : null,
                  )),
                  DataCell(Text(tenant.id?.toString() ?? '-')),
                  DataCell(Text(tenant.name, overflow: TextOverflow.ellipsis)),
                  DataCell(Text(_getPackageName(tenant.packageId), overflow: TextOverflow.ellipsis)),
                  DataCell(Text(tenant.contactName ?? '-')),
                  DataCell(Text(tenant.contactMobile ?? '-')),
                  DataCell(Text(tenant.accountCount?.toString() ?? '-')),
                  DataCell(Text(tenant.expireTime ?? '-')),
                  DataCell(_buildStatusBadge(tenant.status)),
                  DataCell(Text(tenant.createTime ?? '-')),
                  DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => _showFormDialog(tenant),
                        child: const Text('编辑'),
                      ),
                      TextButton(
                        onPressed: () => _deleteTenant(tenant),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('删除'),
                      ),
                    ],
                  )),
                ],
              );
            }).toList(),
            empty: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('暂无数据', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ),
        ),
        _buildDesktopPagination(),
      ],
    );
  }

  Widget _buildDesktopPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
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
      ),
    );
  }
}