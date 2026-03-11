import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:yudao_flutter_ui_admin/i18n/i18n.dart';

/// 表单构建器页面
/// Flutter 简化实现，原 Vue 版本使用 form-create 设计器
class BuildPage extends StatefulWidget {
  const BuildPage({super.key});

  @override
  State<BuildPage> createState() => _BuildPageState();
}

class _BuildPageState extends State<BuildPage> {
  // 表单组件列表
  final List<FormFieldConfig> _formFields = [];

  // 可用的组件类型
  final List<ComponentType> _componentTypes = [
    ComponentType(type: 'input', name: '输入框', icon: Icons.text_fields),
    ComponentType(type: 'textarea', name: '多行文本', icon: Icons.notes),
    ComponentType(type: 'number', name: '数字输入', icon: Icons.pin),
    ComponentType(type: 'select', name: '下拉选择', icon: Icons.arrow_drop_down_circle),
    ComponentType(type: 'radio', name: '单选框', icon: Icons.radio_button_checked),
    ComponentType(type: 'checkbox', name: '复选框', icon: Icons.check_box),
    ComponentType(type: 'date', name: '日期选择', icon: Icons.calendar_today),
    ComponentType(type: 'time', name: '时间选择', icon: Icons.access_time),
    ComponentType(type: 'switch', name: '开关', icon: Icons.toggle_on),
    ComponentType(type: 'slider', name: '滑块', icon: Icons.linear_scale),
    ComponentType(type: 'rate', name: '评分', icon: Icons.star),
    ComponentType(type: 'upload', name: '文件上传', icon: Icons.upload_file),
  ];

  int _selectedFieldIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 左侧：组件库
          Container(
            width: 200,
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    S.current.componentLibrary,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _componentTypes.length,
                    itemBuilder: (context, index) {
                      final component = _componentTypes[index];
                      return Draggable<ComponentType>(
                        data: component,
                        feedback: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(component.icon, size: 20),
                                const SizedBox(width: 8),
                                Text(component.name),
                              ],
                            ),
                          ),
                        ),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 4),
                          child: ListTile(
                            dense: true,
                            leading: Icon(component.icon, size: 20),
                            title: Text(component.name, style: const TextStyle(fontSize: 14)),
                            onTap: () => _addField(component),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 中间：表单设计区域
          Expanded(
            child: DragTarget<ComponentType>(
              onWillAcceptWithDetails: (details) => true,
              onAcceptWithDetails: (details) => _addField(details.data),
              builder: (context, candidateData, rejectedData) {
                return Container(
                  color: candidateData.isNotEmpty ? Colors.blue.withValues(alpha: 0.05) : null,
                  child: Column(
                    children: [
                      // 工具栏
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              S.current.formDesigner,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: _formFields.isEmpty ? null : _showJsonDialog,
                              icon: const Icon(Icons.code),
                              label: const Text('JSON'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _formFields.isEmpty ? null : _previewForm,
                              icon: const Icon(Icons.preview),
                              label: Text(S.current.preview),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: _formFields.isEmpty ? null : _clearForm,
                              icon: const Icon(Icons.clear),
                              label: Text(S.current.clear),
                            ),
                          ],
                        ),
                      ),

                      // 表单设计区域
                      Expanded(
                        child: _formFields.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.drag_indicator, size: 64, color: Colors.grey[400]),
                                    const SizedBox(height: 16),
                                    Text(
                                      S.current.dragComponentHere,
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _formFields.length,
                                itemBuilder: (context, index) {
                                  final field = _formFields[index];
                                  final isSelected = _selectedFieldIndex == index;

                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedFieldIndex = index),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isSelected ? Colors.blue : Colors.grey[300]!,
                                          width: isSelected ? 2 : 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        color: isSelected ? Colors.blue.withValues(alpha: 0.05) : null,
                                      ),
                                      child: ListTile(
                                        leading: Icon(field.componentType.icon),
                                        title: Text(field.label ?? field.field),
                                        subtitle: Text(
                                          '${field.componentType.name} - ${field.field}',
                                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.arrow_upward, size: 20),
                                              onPressed: index > 0
                                                  ? () => _moveField(index, -1)
                                                  : null,
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.arrow_downward, size: 20),
                                              onPressed: index < _formFields.length - 1
                                                  ? () => _moveField(index, 1)
                                                  : null,
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                              onPressed: () => _removeField(index),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 右侧：属性配置
          Container(
            width: 280,
            color: Colors.grey[50],
            child: _selectedFieldIndex >= 0 && _selectedFieldIndex < _formFields.length
                ? _buildPropertyPanel()
                : Center(
                    child: Text(
                      S.current.selectFieldToConfig,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyPanel() {
    final field = _formFields[_selectedFieldIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.current.fieldProperties,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Divider(),
          const SizedBox(height: 8),

          // 字段名
          TextField(
            decoration: InputDecoration(
              labelText: S.current.fieldName,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            controller: TextEditingController(text: field.field),
            onChanged: (value) => setState(() => field.field = value),
          ),
          const SizedBox(height: 12),

          // 标签
          TextField(
            decoration: InputDecoration(
              labelText: S.current.label,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            controller: TextEditingController(text: field.label),
            onChanged: (value) => setState(() => field.label = value),
          ),
          const SizedBox(height: 12),

          // 占位符
          TextField(
            decoration: InputDecoration(
              labelText: S.current.placeholder,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            controller: TextEditingController(text: field.placeholder),
            onChanged: (value) => setState(() => field.placeholder = value),
          ),
          const SizedBox(height: 12),

          // 默认值
          TextField(
            decoration: InputDecoration(
              labelText: S.current.defaultValue,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            controller: TextEditingController(text: field.defaultValue),
            onChanged: (value) => setState(() => field.defaultValue = value),
          ),
          const SizedBox(height: 12),

          // 是否必填
          SwitchListTile(
            title: Text(S.current.required),
            value: field.required,
            onChanged: (value) => setState(() => field.required = value),
          ),
          const SizedBox(height: 12),

          // 是否禁用
          SwitchListTile(
            title: Text(S.current.disabled),
            value: field.disabled,
            onChanged: (value) => setState(() => field.disabled = value),
          ),
        ],
      ),
    );
  }

  void _addField(ComponentType component) {
    setState(() {
      final fieldIndex = _formFields.length + 1;
      _formFields.add(FormFieldConfig(
        field: 'field_$fieldIndex',
        label: '${component.name} $fieldIndex',
        componentType: component,
      ));
      _selectedFieldIndex = _formFields.length - 1;
    });
  }

  void _removeField(int index) {
    setState(() {
      _formFields.removeAt(index);
      if (_selectedFieldIndex >= _formFields.length) {
        _selectedFieldIndex = _formFields.length - 1;
      }
    });
  }

  void _moveField(int index, int direction) {
    setState(() {
      final newIndex = index + direction;
      if (newIndex >= 0 && newIndex < _formFields.length) {
        final field = _formFields.removeAt(index);
        _formFields.insert(newIndex, field);
        _selectedFieldIndex = newIndex;
      }
    });
  }

  void _clearForm() {
    setState(() {
      _formFields.clear();
      _selectedFieldIndex = -1;
    });
  }

  void _showJsonDialog() {
    final json = _generateJson();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Form JSON'),
        content: SizedBox(
          width: 500,
          height: 400,
          child: TextField(
            maxLines: null,
            expands: true,
            readOnly: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              filled: true,
            ),
            controller: TextEditingController(text: json),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.current.close),
          ),
        ],
      ),
    );
  }

  String _generateJson() {
    final fields = _formFields.map((f) => {
      'field': f.field,
      'label': f.label,
      'type': f.componentType.type,
      'placeholder': f.placeholder,
      'defaultValue': f.defaultValue,
      'required': f.required,
      'disabled': f.disabled,
    }).toList();

    return const JsonEncoder.withIndent('  ').convert({
      'fields': fields,
    });
  }

  void _previewForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.current.preview),
        content: SizedBox(
          width: 400,
          height: 500,
          child: SingleChildScrollView(
            child: Column(
              children: _formFields.map((field) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildPreviewField(field),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.current.close),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewField(FormFieldConfig field) {
    final InputDecoration decoration = InputDecoration(
      labelText: field.label,
      hintText: field.placeholder,
      border: const OutlineInputBorder(),
    );

    switch (field.componentType.type) {
      case 'input':
        return TextField(decoration: decoration);
      case 'textarea':
        return TextField(decoration: decoration, maxLines: 3);
      case 'number':
        return TextField(decoration: decoration, keyboardType: TextInputType.number);
      case 'select':
        return DropdownButtonFormField<String>(
          decoration: decoration,
          items: const [
            DropdownMenuItem(value: '1', child: Text('选项1')),
            DropdownMenuItem(value: '2', child: Text('选项2')),
          ],
          onChanged: (_) {},
        );
      case 'radio':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field.label ?? ''),
            Row(
              children: [
                Radio(value: '1', groupValue: null, onChanged: (_) {}),
                const Text('选项1'),
                Radio(value: '2', groupValue: null, onChanged: (_) {}),
                const Text('选项2'),
              ],
            ),
          ],
        );
      case 'checkbox':
        return CheckboxListTile(
          title: Text(field.label ?? ''),
          value: false,
          onChanged: (_) {},
        );
      case 'switch':
        return SwitchListTile(
          title: Text(field.label ?? ''),
          value: false,
          onChanged: (_) {},
        );
      case 'date':
        return TextField(
          decoration: decoration.copyWith(suffixIcon: const Icon(Icons.calendar_today)),
          readOnly: true,
        );
      case 'time':
        return TextField(
          decoration: decoration.copyWith(suffixIcon: const Icon(Icons.access_time)),
          readOnly: true,
        );
      case 'slider':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field.label ?? ''),
            Slider(value: 0.5, onChanged: (_) {}),
          ],
        );
      case 'rate':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field.label ?? ''),
            const Row(children: [
              Icon(Icons.star, color: Colors.amber),
              Icon(Icons.star, color: Colors.amber),
              Icon(Icons.star, color: Colors.amber),
              Icon(Icons.star_border),
              Icon(Icons.star_border),
            ]),
          ],
        );
      case 'upload':
        return OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.upload_file),
          label: Text(field.label ?? S.current.upload),
        );
      default:
        return TextField(decoration: decoration);
    }
  }
}

/// 组件类型
class ComponentType {
  final String type;
  final String name;
  final IconData icon;

  const ComponentType({
    required this.type,
    required this.name,
    required this.icon,
  });
}

/// 表单字段配置
class FormFieldConfig {
  String field;
  String? label;
  String? placeholder;
  String? defaultValue;
  bool required;
  bool disabled;
  ComponentType componentType;

  FormFieldConfig({
    required this.field,
    this.label,
    this.placeholder,
    this.defaultValue,
    this.required = false,
    this.disabled = false,
    required this.componentType,
  });
}