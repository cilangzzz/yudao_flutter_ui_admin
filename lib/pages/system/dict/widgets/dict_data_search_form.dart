import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 字典数据搜索表单组件
class DictDataSearchForm extends StatelessWidget {
  final String? selectedDictType;
  final TextEditingController searchController;
  final int? selectedStatus;
  final void Function(int? status) onStatusChanged;
  final VoidCallback onSearch;
  final VoidCallback onReset;

  const DictDataSearchForm({
    super.key,
    required this.selectedDictType,
    required this.searchController,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onSearch,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '${S.current.currentDictType}: ${selectedDictType ?? S.current.pleaseSelectDictType}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(
            width: 180,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: S.current.dataLabel,
                prefixIcon: const Icon(Icons.search, size: 20),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          SizedBox(
            width: 120,
            child: DropdownButtonFormField<int?>(
              value: selectedStatus,
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
                onStatusChanged(value);
                onSearch();
              },
            ),
          ),
          ElevatedButton.icon(
            onPressed: selectedDictType == null ? null : onSearch,
            icon: const Icon(Icons.search, size: 20),
            label: Text(S.current.search),
          ),
          OutlinedButton.icon(
            onPressed: selectedDictType == null ? null : onReset,
            icon: const Icon(Icons.refresh, size: 20),
            label: Text(S.current.reset),
          ),
        ],
      ),
    );
  }
}