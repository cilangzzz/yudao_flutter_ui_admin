import 'package:flutter/material.dart';
import 'dict_type_page.dart';
import 'dict_data_page.dart';

/// 字典管理主页面
/// 左侧显示字典类型列表，右侧显示字典数据列表
class DictPage extends StatefulWidget {
  const DictPage({super.key});

  @override
  State<DictPage> createState() => _DictPageState();
}

class _DictPageState extends State<DictPage> {
  String? _selectedDictType;

  void _handleDictTypeSelect(String dictType) {
    setState(() {
      _selectedDictType = dictType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 左侧字典类型列表
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: DictTypePage(
              onSelect: _handleDictTypeSelect,
            ),
          ),
          const VerticalDivider(width: 1),
          // 右侧字典数据列表
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: DictDataPage(
              dictType: _selectedDictType,
            ),
          ),
        ],
      ),
    );
  }
}