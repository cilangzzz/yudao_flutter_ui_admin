/// 代码生成表定义
class CodegenTable {
  final int? id;
  final int? tableId;
  final bool? isParentMenuIdValid;
  final int? dataSourceConfigId;
  final int? scene;
  final String? tableName;
  final String? tableComment;
  final String? remark;
  final String? moduleName;
  final String? businessName;
  final String? className;
  final String? classComment;
  final String? author;
  final String? createTime;
  final String? updateTime;
  final int? templateType;
  final int? parentMenuId;
  final int? frontType;
  // 树表相关
  final int? treeParentColumnId;
  final int? treeNameColumnId;
  // 主子表相关
  final int? masterTableId;
  final int? subJoinColumnId;
  final bool? subJoinMany;

  CodegenTable({
    this.id,
    this.tableId,
    this.isParentMenuIdValid,
    this.dataSourceConfigId,
    this.scene,
    this.tableName,
    this.tableComment,
    this.remark,
    this.moduleName,
    this.businessName,
    this.className,
    this.classComment,
    this.author,
    this.createTime,
    this.updateTime,
    this.templateType,
    this.parentMenuId,
    this.frontType,
    this.treeParentColumnId,
    this.treeNameColumnId,
    this.masterTableId,
    this.subJoinColumnId,
    this.subJoinMany,
  });

  factory CodegenTable.fromJson(Map<String, dynamic> json) {
    return CodegenTable(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      tableId: json['tableId'] is int ? json['tableId'] : int.tryParse(json['tableId']?.toString() ?? ''),
      isParentMenuIdValid: json['isParentMenuIdValid'] as bool?,
      dataSourceConfigId: json['dataSourceConfigId'] is int ? json['dataSourceConfigId'] : int.tryParse(json['dataSourceConfigId']?.toString() ?? ''),
      scene: json['scene'] is int ? json['scene'] : int.tryParse(json['scene']?.toString() ?? ''),
      tableName: json['tableName']?.toString(),
      tableComment: json['tableComment']?.toString(),
      remark: json['remark']?.toString(),
      moduleName: json['moduleName']?.toString(),
      businessName: json['businessName']?.toString(),
      className: json['className']?.toString(),
      classComment: json['classComment']?.toString(),
      author: json['author']?.toString(),
      createTime: json['createTime']?.toString(),
      updateTime: json['updateTime']?.toString(),
      templateType: json['templateType'] is int ? json['templateType'] : int.tryParse(json['templateType']?.toString() ?? ''),
      parentMenuId: json['parentMenuId'] is int ? json['parentMenuId'] : int.tryParse(json['parentMenuId']?.toString() ?? ''),
      frontType: json['frontType'] is int ? json['frontType'] : int.tryParse(json['frontType']?.toString() ?? ''),
      treeParentColumnId: json['treeParentColumnId'] is int ? json['treeParentColumnId'] : int.tryParse(json['treeParentColumnId']?.toString() ?? ''),
      treeNameColumnId: json['treeNameColumnId'] is int ? json['treeNameColumnId'] : int.tryParse(json['treeNameColumnId']?.toString() ?? ''),
      masterTableId: json['masterTableId'] is int ? json['masterTableId'] : int.tryParse(json['masterTableId']?.toString() ?? ''),
      subJoinColumnId: json['subJoinColumnId'] is int ? json['subJoinColumnId'] : int.tryParse(json['subJoinColumnId']?.toString() ?? ''),
      subJoinMany: json['subJoinMany'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (tableId != null) 'tableId': tableId,
      if (isParentMenuIdValid != null) 'isParentMenuIdValid': isParentMenuIdValid,
      if (dataSourceConfigId != null) 'dataSourceConfigId': dataSourceConfigId,
      if (scene != null) 'scene': scene,
      if (tableName != null) 'tableName': tableName,
      if (tableComment != null) 'tableComment': tableComment,
      if (remark != null) 'remark': remark,
      if (moduleName != null) 'moduleName': moduleName,
      if (businessName != null) 'businessName': businessName,
      if (className != null) 'className': className,
      if (classComment != null) 'classComment': classComment,
      if (author != null) 'author': author,
      if (createTime != null) 'createTime': createTime,
      if (updateTime != null) 'updateTime': updateTime,
      if (templateType != null) 'templateType': templateType,
      if (parentMenuId != null) 'parentMenuId': parentMenuId,
      if (frontType != null) 'frontType': frontType,
      if (treeParentColumnId != null) 'treeParentColumnId': treeParentColumnId,
      if (treeNameColumnId != null) 'treeNameColumnId': treeNameColumnId,
      if (masterTableId != null) 'masterTableId': masterTableId,
      if (subJoinColumnId != null) 'subJoinColumnId': subJoinColumnId,
      if (subJoinMany != null) 'subJoinMany': subJoinMany,
    };
  }

  CodegenTable copyWith({
    int? id,
    int? tableId,
    bool? isParentMenuIdValid,
    int? dataSourceConfigId,
    int? scene,
    String? tableName,
    String? tableComment,
    String? remark,
    String? moduleName,
    String? businessName,
    String? className,
    String? classComment,
    String? author,
    String? createTime,
    String? updateTime,
    int? templateType,
    int? parentMenuId,
    int? frontType,
    int? treeParentColumnId,
    int? treeNameColumnId,
    int? masterTableId,
    int? subJoinColumnId,
    bool? subJoinMany,
  }) {
    return CodegenTable(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      isParentMenuIdValid: isParentMenuIdValid ?? this.isParentMenuIdValid,
      dataSourceConfigId: dataSourceConfigId ?? this.dataSourceConfigId,
      scene: scene ?? this.scene,
      tableName: tableName ?? this.tableName,
      tableComment: tableComment ?? this.tableComment,
      remark: remark ?? this.remark,
      moduleName: moduleName ?? this.moduleName,
      businessName: businessName ?? this.businessName,
      className: className ?? this.className,
      classComment: classComment ?? this.classComment,
      author: author ?? this.author,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
      templateType: templateType ?? this.templateType,
      parentMenuId: parentMenuId ?? this.parentMenuId,
      frontType: frontType ?? this.frontType,
      treeParentColumnId: treeParentColumnId ?? this.treeParentColumnId,
      treeNameColumnId: treeNameColumnId ?? this.treeNameColumnId,
      masterTableId: masterTableId ?? this.masterTableId,
      subJoinColumnId: subJoinColumnId ?? this.subJoinColumnId,
      subJoinMany: subJoinMany ?? this.subJoinMany,
    );
  }
}

/// 代码生成字段定义
class CodegenColumn {
  final int? id;
  final int? tableId;
  final String? columnName;
  final String? dataType;
  final String? columnComment;
  final int? nullable;
  final int? primaryKey;
  final int? ordinalPosition;
  final String? javaType;
  final String? javaField;
  final String? dictType;
  final String? example;
  final int? createOperation;
  final int? updateOperation;
  final int? listOperation;
  final String? listOperationCondition;
  final int? listOperationResult;
  final String? htmlType;

  CodegenColumn({
    this.id,
    this.tableId,
    this.columnName,
    this.dataType,
    this.columnComment,
    this.nullable,
    this.primaryKey,
    this.ordinalPosition,
    this.javaType,
    this.javaField,
    this.dictType,
    this.example,
    this.createOperation,
    this.updateOperation,
    this.listOperation,
    this.listOperationCondition,
    this.listOperationResult,
    this.htmlType,
  });

  factory CodegenColumn.fromJson(Map<String, dynamic> json) {
    return CodegenColumn(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      tableId: json['tableId'] is int ? json['tableId'] : int.tryParse(json['tableId']?.toString() ?? ''),
      columnName: json['columnName']?.toString(),
      dataType: json['dataType']?.toString(),
      columnComment: json['columnComment']?.toString(),
      nullable: json['nullable'] is int ? json['nullable'] : int.tryParse(json['nullable']?.toString() ?? ''),
      primaryKey: json['primaryKey'] is int ? json['primaryKey'] : int.tryParse(json['primaryKey']?.toString() ?? ''),
      ordinalPosition: json['ordinalPosition'] is int ? json['ordinalPosition'] : int.tryParse(json['ordinalPosition']?.toString() ?? ''),
      javaType: json['javaType']?.toString(),
      javaField: json['javaField']?.toString(),
      dictType: json['dictType']?.toString(),
      example: json['example']?.toString(),
      createOperation: json['createOperation'] is int ? json['createOperation'] : int.tryParse(json['createOperation']?.toString() ?? ''),
      updateOperation: json['updateOperation'] is int ? json['updateOperation'] : int.tryParse(json['updateOperation']?.toString() ?? ''),
      listOperation: json['listOperation'] is int ? json['listOperation'] : int.tryParse(json['listOperation']?.toString() ?? ''),
      listOperationCondition: json['listOperationCondition']?.toString(),
      listOperationResult: json['listOperationResult'] is int ? json['listOperationResult'] : int.tryParse(json['listOperationResult']?.toString() ?? ''),
      htmlType: json['htmlType']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (tableId != null) 'tableId': tableId,
      if (columnName != null) 'columnName': columnName,
      if (dataType != null) 'dataType': dataType,
      if (columnComment != null) 'columnComment': columnComment,
      if (nullable != null) 'nullable': nullable,
      if (primaryKey != null) 'primaryKey': primaryKey,
      if (ordinalPosition != null) 'ordinalPosition': ordinalPosition,
      if (javaType != null) 'javaType': javaType,
      if (javaField != null) 'javaField': javaField,
      if (dictType != null) 'dictType': dictType,
      if (example != null) 'example': example,
      if (createOperation != null) 'createOperation': createOperation,
      if (updateOperation != null) 'updateOperation': updateOperation,
      if (listOperation != null) 'listOperation': listOperation,
      if (listOperationCondition != null) 'listOperationCondition': listOperationCondition,
      if (listOperationResult != null) 'listOperationResult': listOperationResult,
      if (htmlType != null) 'htmlType': htmlType,
    };
  }

  CodegenColumn copyWith({
    int? id,
    int? tableId,
    String? columnName,
    String? dataType,
    String? columnComment,
    int? nullable,
    int? primaryKey,
    int? ordinalPosition,
    String? javaType,
    String? javaField,
    String? dictType,
    String? example,
    int? createOperation,
    int? updateOperation,
    int? listOperation,
    String? listOperationCondition,
    int? listOperationResult,
    String? htmlType,
  }) {
    return CodegenColumn(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      columnName: columnName ?? this.columnName,
      dataType: dataType ?? this.dataType,
      columnComment: columnComment ?? this.columnComment,
      nullable: nullable ?? this.nullable,
      primaryKey: primaryKey ?? this.primaryKey,
      ordinalPosition: ordinalPosition ?? this.ordinalPosition,
      javaType: javaType ?? this.javaType,
      javaField: javaField ?? this.javaField,
      dictType: dictType ?? this.dictType,
      example: example ?? this.example,
      createOperation: createOperation ?? this.createOperation,
      updateOperation: updateOperation ?? this.updateOperation,
      listOperation: listOperation ?? this.listOperation,
      listOperationCondition: listOperationCondition ?? this.listOperationCondition,
      listOperationResult: listOperationResult ?? this.listOperationResult,
      htmlType: htmlType ?? this.htmlType,
    );
  }
}

/// 数据库表定义
class DatabaseTable {
  final String? name;
  final String? comment;

  DatabaseTable({
    this.name,
    this.comment,
  });

  factory DatabaseTable.fromJson(Map<String, dynamic> json) {
    return DatabaseTable(
      name: json['name']?.toString(),
      comment: json['comment']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (comment != null) 'comment': comment,
    };
  }
}

/// 代码生成详情
class CodegenDetail {
  final CodegenTable? table;
  final List<CodegenColumn> columns;

  CodegenDetail({
    this.table,
    this.columns = const [],
  });

  factory CodegenDetail.fromJson(Map<String, dynamic> json) {
    return CodegenDetail(
      table: json['table'] != null ? CodegenTable.fromJson(json['table'] as Map<String, dynamic>) : null,
      columns: json['columns'] != null
          ? (json['columns'] as List<dynamic>)
              .map((e) => CodegenColumn.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (table != null) 'table': table!.toJson(),
      'columns': columns.map((e) => e.toJson()).toList(),
    };
  }
}

/// 代码预览
class CodegenPreview {
  final String? filePath;
  final String? code;

  CodegenPreview({
    this.filePath,
    this.code,
  });

  factory CodegenPreview.fromJson(Map<String, dynamic> json) {
    return CodegenPreview(
      filePath: json['filePath']?.toString(),
      code: json['code']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (filePath != null) 'filePath': filePath,
      if (code != null) 'code': code,
    };
  }
}

/// 更新代码生成请求
class CodegenUpdateReq {
  final CodegenTable? table;
  final List<CodegenColumn> columns;

  CodegenUpdateReq({
    this.table,
    this.columns = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      if (table != null) 'table': table!.toJson(),
      'columns': columns.map((e) => e.toJson()).toList(),
    };
  }
}

/// 创建代码生成请求
class CodegenCreateReq {
  final int? dataSourceConfigId;
  final List<String> tableNames;

  CodegenCreateReq({
    this.dataSourceConfigId,
    this.tableNames = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      if (dataSourceConfigId != null) 'dataSourceConfigId': dataSourceConfigId,
      'tableNames': tableNames,
    };
  }
}

/// 数据源配置
class DataSourceConfig {
  final int? id;
  final String? name;
  final String? url;
  final String? username;
  final String? password;

  DataSourceConfig({
    this.id,
    this.name,
    this.url,
    this.username,
    this.password,
  });

  factory DataSourceConfig.fromJson(Map<String, dynamic> json) {
    return DataSourceConfig(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      url: json['url']?.toString(),
      username: json['username']?.toString(),
      password: json['password']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (url != null) 'url': url,
      if (username != null) 'username': username,
    };
  }
}