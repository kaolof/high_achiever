// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_database.dart';

// ignore_for_file: type=lint
class $TemplateSettingsTable extends TemplateSettings
    with TableInfo<$TemplateSettingsTable, TemplateSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TemplateSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _daysPerWeekMeta = const VerificationMeta(
    'daysPerWeek',
  );
  @override
  late final GeneratedColumn<int> daysPerWeek = GeneratedColumn<int>(
    'days_per_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _weekStartDayMeta = const VerificationMeta(
    'weekStartDay',
  );
  @override
  late final GeneratedColumn<int> weekStartDay = GeneratedColumn<int>(
    'week_start_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _weeklyGoalMeta = const VerificationMeta(
    'weeklyGoal',
  );
  @override
  late final GeneratedColumn<int> weeklyGoal = GeneratedColumn<int>(
    'weekly_goal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(18),
  );
  static const VerificationMeta _rewardMeta = const VerificationMeta('reward');
  @override
  late final GeneratedColumn<String> reward = GeneratedColumn<String>(
    'reward',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    daysPerWeek,
    weekStartDay,
    weeklyGoal,
    reward,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'template_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<TemplateSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('days_per_week')) {
      context.handle(
        _daysPerWeekMeta,
        daysPerWeek.isAcceptableOrUnknown(
          data['days_per_week']!,
          _daysPerWeekMeta,
        ),
      );
    }
    if (data.containsKey('week_start_day')) {
      context.handle(
        _weekStartDayMeta,
        weekStartDay.isAcceptableOrUnknown(
          data['week_start_day']!,
          _weekStartDayMeta,
        ),
      );
    }
    if (data.containsKey('weekly_goal')) {
      context.handle(
        _weeklyGoalMeta,
        weeklyGoal.isAcceptableOrUnknown(data['weekly_goal']!, _weeklyGoalMeta),
      );
    }
    if (data.containsKey('reward')) {
      context.handle(
        _rewardMeta,
        reward.isAcceptableOrUnknown(data['reward']!, _rewardMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TemplateSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TemplateSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      daysPerWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days_per_week'],
      )!,
      weekStartDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}week_start_day'],
      )!,
      weeklyGoal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekly_goal'],
      )!,
      reward: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reward'],
      )!,
    );
  }

  @override
  $TemplateSettingsTable createAlias(String alias) {
    return $TemplateSettingsTable(attachedDatabase, alias);
  }
}

class TemplateSetting extends DataClass implements Insertable<TemplateSetting> {
  final int id;
  final int daysPerWeek;
  final int weekStartDay;
  final int weeklyGoal;
  final String reward;
  const TemplateSetting({
    required this.id,
    required this.daysPerWeek,
    required this.weekStartDay,
    required this.weeklyGoal,
    required this.reward,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['days_per_week'] = Variable<int>(daysPerWeek);
    map['week_start_day'] = Variable<int>(weekStartDay);
    map['weekly_goal'] = Variable<int>(weeklyGoal);
    map['reward'] = Variable<String>(reward);
    return map;
  }

  TemplateSettingsCompanion toCompanion(bool nullToAbsent) {
    return TemplateSettingsCompanion(
      id: Value(id),
      daysPerWeek: Value(daysPerWeek),
      weekStartDay: Value(weekStartDay),
      weeklyGoal: Value(weeklyGoal),
      reward: Value(reward),
    );
  }

  factory TemplateSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TemplateSetting(
      id: serializer.fromJson<int>(json['id']),
      daysPerWeek: serializer.fromJson<int>(json['daysPerWeek']),
      weekStartDay: serializer.fromJson<int>(json['weekStartDay']),
      weeklyGoal: serializer.fromJson<int>(json['weeklyGoal']),
      reward: serializer.fromJson<String>(json['reward']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'daysPerWeek': serializer.toJson<int>(daysPerWeek),
      'weekStartDay': serializer.toJson<int>(weekStartDay),
      'weeklyGoal': serializer.toJson<int>(weeklyGoal),
      'reward': serializer.toJson<String>(reward),
    };
  }

  TemplateSetting copyWith({
    int? id,
    int? daysPerWeek,
    int? weekStartDay,
    int? weeklyGoal,
    String? reward,
  }) => TemplateSetting(
    id: id ?? this.id,
    daysPerWeek: daysPerWeek ?? this.daysPerWeek,
    weekStartDay: weekStartDay ?? this.weekStartDay,
    weeklyGoal: weeklyGoal ?? this.weeklyGoal,
    reward: reward ?? this.reward,
  );
  TemplateSetting copyWithCompanion(TemplateSettingsCompanion data) {
    return TemplateSetting(
      id: data.id.present ? data.id.value : this.id,
      daysPerWeek: data.daysPerWeek.present
          ? data.daysPerWeek.value
          : this.daysPerWeek,
      weekStartDay: data.weekStartDay.present
          ? data.weekStartDay.value
          : this.weekStartDay,
      weeklyGoal: data.weeklyGoal.present
          ? data.weeklyGoal.value
          : this.weeklyGoal,
      reward: data.reward.present ? data.reward.value : this.reward,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TemplateSetting(')
          ..write('id: $id, ')
          ..write('daysPerWeek: $daysPerWeek, ')
          ..write('weekStartDay: $weekStartDay, ')
          ..write('weeklyGoal: $weeklyGoal, ')
          ..write('reward: $reward')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, daysPerWeek, weekStartDay, weeklyGoal, reward);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TemplateSetting &&
          other.id == this.id &&
          other.daysPerWeek == this.daysPerWeek &&
          other.weekStartDay == this.weekStartDay &&
          other.weeklyGoal == this.weeklyGoal &&
          other.reward == this.reward);
}

class TemplateSettingsCompanion extends UpdateCompanion<TemplateSetting> {
  final Value<int> id;
  final Value<int> daysPerWeek;
  final Value<int> weekStartDay;
  final Value<int> weeklyGoal;
  final Value<String> reward;
  const TemplateSettingsCompanion({
    this.id = const Value.absent(),
    this.daysPerWeek = const Value.absent(),
    this.weekStartDay = const Value.absent(),
    this.weeklyGoal = const Value.absent(),
    this.reward = const Value.absent(),
  });
  TemplateSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.daysPerWeek = const Value.absent(),
    this.weekStartDay = const Value.absent(),
    this.weeklyGoal = const Value.absent(),
    this.reward = const Value.absent(),
  });
  static Insertable<TemplateSetting> custom({
    Expression<int>? id,
    Expression<int>? daysPerWeek,
    Expression<int>? weekStartDay,
    Expression<int>? weeklyGoal,
    Expression<String>? reward,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (daysPerWeek != null) 'days_per_week': daysPerWeek,
      if (weekStartDay != null) 'week_start_day': weekStartDay,
      if (weeklyGoal != null) 'weekly_goal': weeklyGoal,
      if (reward != null) 'reward': reward,
    });
  }

  TemplateSettingsCompanion copyWith({
    Value<int>? id,
    Value<int>? daysPerWeek,
    Value<int>? weekStartDay,
    Value<int>? weeklyGoal,
    Value<String>? reward,
  }) {
    return TemplateSettingsCompanion(
      id: id ?? this.id,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      weekStartDay: weekStartDay ?? this.weekStartDay,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
      reward: reward ?? this.reward,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (daysPerWeek.present) {
      map['days_per_week'] = Variable<int>(daysPerWeek.value);
    }
    if (weekStartDay.present) {
      map['week_start_day'] = Variable<int>(weekStartDay.value);
    }
    if (weeklyGoal.present) {
      map['weekly_goal'] = Variable<int>(weeklyGoal.value);
    }
    if (reward.present) {
      map['reward'] = Variable<String>(reward.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TemplateSettingsCompanion(')
          ..write('id: $id, ')
          ..write('daysPerWeek: $daysPerWeek, ')
          ..write('weekStartDay: $weekStartDay, ')
          ..write('weeklyGoal: $weeklyGoal, ')
          ..write('reward: $reward')
          ..write(')'))
        .toString();
  }
}

class $TaskRowsTable extends TaskRows with TableInfo<$TaskRowsTable, TaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minPerWeekMeta = const VerificationMeta(
    'minPerWeek',
  );
  @override
  late final GeneratedColumn<int> minPerWeek = GeneratedColumn<int>(
    'min_per_week',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxPerWeekMeta = const VerificationMeta(
    'maxPerWeek',
  );
  @override
  late final GeneratedColumn<int> maxPerWeek = GeneratedColumn<int>(
    'max_per_week',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    position,
    minPerWeek,
    maxPerWeek,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('min_per_week')) {
      context.handle(
        _minPerWeekMeta,
        minPerWeek.isAcceptableOrUnknown(
          data['min_per_week']!,
          _minPerWeekMeta,
        ),
      );
    }
    if (data.containsKey('max_per_week')) {
      context.handle(
        _maxPerWeekMeta,
        maxPerWeek.isAcceptableOrUnknown(
          data['max_per_week']!,
          _maxPerWeekMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      minPerWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_per_week'],
      ),
      maxPerWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_per_week'],
      ),
    );
  }

  @override
  $TaskRowsTable createAlias(String alias) {
    return $TaskRowsTable(attachedDatabase, alias);
  }
}

class TaskRow extends DataClass implements Insertable<TaskRow> {
  final String id;
  final String name;
  final int position;
  final int? minPerWeek;
  final int? maxPerWeek;
  const TaskRow({
    required this.id,
    required this.name,
    required this.position,
    this.minPerWeek,
    this.maxPerWeek,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || minPerWeek != null) {
      map['min_per_week'] = Variable<int>(minPerWeek);
    }
    if (!nullToAbsent || maxPerWeek != null) {
      map['max_per_week'] = Variable<int>(maxPerWeek);
    }
    return map;
  }

  TaskRowsCompanion toCompanion(bool nullToAbsent) {
    return TaskRowsCompanion(
      id: Value(id),
      name: Value(name),
      position: Value(position),
      minPerWeek: minPerWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(minPerWeek),
      maxPerWeek: maxPerWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(maxPerWeek),
    );
  }

  factory TaskRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      position: serializer.fromJson<int>(json['position']),
      minPerWeek: serializer.fromJson<int?>(json['minPerWeek']),
      maxPerWeek: serializer.fromJson<int?>(json['maxPerWeek']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'position': serializer.toJson<int>(position),
      'minPerWeek': serializer.toJson<int?>(minPerWeek),
      'maxPerWeek': serializer.toJson<int?>(maxPerWeek),
    };
  }

  TaskRow copyWith({
    String? id,
    String? name,
    int? position,
    Value<int?> minPerWeek = const Value.absent(),
    Value<int?> maxPerWeek = const Value.absent(),
  }) => TaskRow(
    id: id ?? this.id,
    name: name ?? this.name,
    position: position ?? this.position,
    minPerWeek: minPerWeek.present ? minPerWeek.value : this.minPerWeek,
    maxPerWeek: maxPerWeek.present ? maxPerWeek.value : this.maxPerWeek,
  );
  TaskRow copyWithCompanion(TaskRowsCompanion data) {
    return TaskRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      position: data.position.present ? data.position.value : this.position,
      minPerWeek: data.minPerWeek.present
          ? data.minPerWeek.value
          : this.minPerWeek,
      maxPerWeek: data.maxPerWeek.present
          ? data.maxPerWeek.value
          : this.maxPerWeek,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('minPerWeek: $minPerWeek, ')
          ..write('maxPerWeek: $maxPerWeek')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, position, minPerWeek, maxPerWeek);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.position == this.position &&
          other.minPerWeek == this.minPerWeek &&
          other.maxPerWeek == this.maxPerWeek);
}

class TaskRowsCompanion extends UpdateCompanion<TaskRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> position;
  final Value<int?> minPerWeek;
  final Value<int?> maxPerWeek;
  final Value<int> rowid;
  const TaskRowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.position = const Value.absent(),
    this.minPerWeek = const Value.absent(),
    this.maxPerWeek = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskRowsCompanion.insert({
    required String id,
    required String name,
    required int position,
    this.minPerWeek = const Value.absent(),
    this.maxPerWeek = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       position = Value(position);
  static Insertable<TaskRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? position,
    Expression<int>? minPerWeek,
    Expression<int>? maxPerWeek,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (position != null) 'position': position,
      if (minPerWeek != null) 'min_per_week': minPerWeek,
      if (maxPerWeek != null) 'max_per_week': maxPerWeek,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? position,
    Value<int?>? minPerWeek,
    Value<int?>? maxPerWeek,
    Value<int>? rowid,
  }) {
    return TaskRowsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      minPerWeek: minPerWeek ?? this.minPerWeek,
      maxPerWeek: maxPerWeek ?? this.maxPerWeek,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (minPerWeek.present) {
      map['min_per_week'] = Variable<int>(minPerWeek.value);
    }
    if (maxPerWeek.present) {
      map['max_per_week'] = Variable<int>(maxPerWeek.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskRowsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('minPerWeek: $minPerWeek, ')
          ..write('maxPerWeek: $maxPerWeek, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompletionsTable extends Completions
    with TableInfo<$CompletionsTable, Completion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [day, taskId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Completion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day, taskId};
  @override
  Completion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Completion(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
    );
  }

  @override
  $CompletionsTable createAlias(String alias) {
    return $CompletionsTable(attachedDatabase, alias);
  }
}

class Completion extends DataClass implements Insertable<Completion> {
  final String day;
  final String taskId;
  const Completion({required this.day, required this.taskId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    map['task_id'] = Variable<String>(taskId);
    return map;
  }

  CompletionsCompanion toCompanion(bool nullToAbsent) {
    return CompletionsCompanion(day: Value(day), taskId: Value(taskId));
  }

  factory Completion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Completion(
      day: serializer.fromJson<String>(json['day']),
      taskId: serializer.fromJson<String>(json['taskId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'taskId': serializer.toJson<String>(taskId),
    };
  }

  Completion copyWith({String? day, String? taskId}) =>
      Completion(day: day ?? this.day, taskId: taskId ?? this.taskId);
  Completion copyWithCompanion(CompletionsCompanion data) {
    return Completion(
      day: data.day.present ? data.day.value : this.day,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Completion(')
          ..write('day: $day, ')
          ..write('taskId: $taskId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, taskId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Completion &&
          other.day == this.day &&
          other.taskId == this.taskId);
}

class CompletionsCompanion extends UpdateCompanion<Completion> {
  final Value<String> day;
  final Value<String> taskId;
  final Value<int> rowid;
  const CompletionsCompanion({
    this.day = const Value.absent(),
    this.taskId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompletionsCompanion.insert({
    required String day,
    required String taskId,
    this.rowid = const Value.absent(),
  }) : day = Value(day),
       taskId = Value(taskId);
  static Insertable<Completion> custom({
    Expression<String>? day,
    Expression<String>? taskId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (taskId != null) 'task_id': taskId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompletionsCompanion copyWith({
    Value<String>? day,
    Value<String>? taskId,
    Value<int>? rowid,
  }) {
    return CompletionsCompanion(
      day: day ?? this.day,
      taskId: taskId ?? this.taskId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompletionsCompanion(')
          ..write('day: $day, ')
          ..write('taskId: $taskId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeekClaimsTable extends WeekClaims
    with TableInfo<$WeekClaimsTable, WeekClaim> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeekClaimsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _weekStartMeta = const VerificationMeta(
    'weekStart',
  );
  @override
  late final GeneratedColumn<String> weekStart = GeneratedColumn<String>(
    'week_start',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [weekStart];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'week_claims';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeekClaim> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('week_start')) {
      context.handle(
        _weekStartMeta,
        weekStart.isAcceptableOrUnknown(data['week_start']!, _weekStartMeta),
      );
    } else if (isInserting) {
      context.missing(_weekStartMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {weekStart};
  @override
  WeekClaim map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeekClaim(
      weekStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}week_start'],
      )!,
    );
  }

  @override
  $WeekClaimsTable createAlias(String alias) {
    return $WeekClaimsTable(attachedDatabase, alias);
  }
}

class WeekClaim extends DataClass implements Insertable<WeekClaim> {
  final String weekStart;
  const WeekClaim({required this.weekStart});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['week_start'] = Variable<String>(weekStart);
    return map;
  }

  WeekClaimsCompanion toCompanion(bool nullToAbsent) {
    return WeekClaimsCompanion(weekStart: Value(weekStart));
  }

  factory WeekClaim.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeekClaim(weekStart: serializer.fromJson<String>(json['weekStart']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'weekStart': serializer.toJson<String>(weekStart)};
  }

  WeekClaim copyWith({String? weekStart}) =>
      WeekClaim(weekStart: weekStart ?? this.weekStart);
  WeekClaim copyWithCompanion(WeekClaimsCompanion data) {
    return WeekClaim(
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeekClaim(')
          ..write('weekStart: $weekStart')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => weekStart.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeekClaim && other.weekStart == this.weekStart);
}

class WeekClaimsCompanion extends UpdateCompanion<WeekClaim> {
  final Value<String> weekStart;
  final Value<int> rowid;
  const WeekClaimsCompanion({
    this.weekStart = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeekClaimsCompanion.insert({
    required String weekStart,
    this.rowid = const Value.absent(),
  }) : weekStart = Value(weekStart);
  static Insertable<WeekClaim> custom({
    Expression<String>? weekStart,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (weekStart != null) 'week_start': weekStart,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeekClaimsCompanion copyWith({Value<String>? weekStart, Value<int>? rowid}) {
    return WeekClaimsCompanion(
      weekStart: weekStart ?? this.weekStart,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (weekStart.present) {
      map['week_start'] = Variable<String>(weekStart.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeekClaimsCompanion(')
          ..write('weekStart: $weekStart, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RewardTierRowsTable extends RewardTierRows
    with TableInfo<$RewardTierRowsTable, RewardTierRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RewardTierRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thresholdMeta = const VerificationMeta(
    'threshold',
  );
  @override
  late final GeneratedColumn<int> threshold = GeneratedColumn<int>(
    'threshold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rewardMeta = const VerificationMeta('reward');
  @override
  late final GeneratedColumn<String> reward = GeneratedColumn<String>(
    'reward',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repeatableMeta = const VerificationMeta(
    'repeatable',
  );
  @override
  late final GeneratedColumn<bool> repeatable = GeneratedColumn<bool>(
    'repeatable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("repeatable" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    position,
    threshold,
    reward,
    repeatable,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reward_tier_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<RewardTierRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('threshold')) {
      context.handle(
        _thresholdMeta,
        threshold.isAcceptableOrUnknown(data['threshold']!, _thresholdMeta),
      );
    } else if (isInserting) {
      context.missing(_thresholdMeta);
    }
    if (data.containsKey('reward')) {
      context.handle(
        _rewardMeta,
        reward.isAcceptableOrUnknown(data['reward']!, _rewardMeta),
      );
    } else if (isInserting) {
      context.missing(_rewardMeta);
    }
    if (data.containsKey('repeatable')) {
      context.handle(
        _repeatableMeta,
        repeatable.isAcceptableOrUnknown(data['repeatable']!, _repeatableMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {position};
  @override
  RewardTierRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RewardTierRow(
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      threshold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}threshold'],
      )!,
      reward: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reward'],
      )!,
      repeatable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}repeatable'],
      )!,
    );
  }

  @override
  $RewardTierRowsTable createAlias(String alias) {
    return $RewardTierRowsTable(attachedDatabase, alias);
  }
}

class RewardTierRow extends DataClass implements Insertable<RewardTierRow> {
  final int position;
  final int threshold;
  final String reward;
  final bool repeatable;
  const RewardTierRow({
    required this.position,
    required this.threshold,
    required this.reward,
    required this.repeatable,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['position'] = Variable<int>(position);
    map['threshold'] = Variable<int>(threshold);
    map['reward'] = Variable<String>(reward);
    map['repeatable'] = Variable<bool>(repeatable);
    return map;
  }

  RewardTierRowsCompanion toCompanion(bool nullToAbsent) {
    return RewardTierRowsCompanion(
      position: Value(position),
      threshold: Value(threshold),
      reward: Value(reward),
      repeatable: Value(repeatable),
    );
  }

  factory RewardTierRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RewardTierRow(
      position: serializer.fromJson<int>(json['position']),
      threshold: serializer.fromJson<int>(json['threshold']),
      reward: serializer.fromJson<String>(json['reward']),
      repeatable: serializer.fromJson<bool>(json['repeatable']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'position': serializer.toJson<int>(position),
      'threshold': serializer.toJson<int>(threshold),
      'reward': serializer.toJson<String>(reward),
      'repeatable': serializer.toJson<bool>(repeatable),
    };
  }

  RewardTierRow copyWith({
    int? position,
    int? threshold,
    String? reward,
    bool? repeatable,
  }) => RewardTierRow(
    position: position ?? this.position,
    threshold: threshold ?? this.threshold,
    reward: reward ?? this.reward,
    repeatable: repeatable ?? this.repeatable,
  );
  RewardTierRow copyWithCompanion(RewardTierRowsCompanion data) {
    return RewardTierRow(
      position: data.position.present ? data.position.value : this.position,
      threshold: data.threshold.present ? data.threshold.value : this.threshold,
      reward: data.reward.present ? data.reward.value : this.reward,
      repeatable: data.repeatable.present
          ? data.repeatable.value
          : this.repeatable,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RewardTierRow(')
          ..write('position: $position, ')
          ..write('threshold: $threshold, ')
          ..write('reward: $reward, ')
          ..write('repeatable: $repeatable')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(position, threshold, reward, repeatable);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RewardTierRow &&
          other.position == this.position &&
          other.threshold == this.threshold &&
          other.reward == this.reward &&
          other.repeatable == this.repeatable);
}

class RewardTierRowsCompanion extends UpdateCompanion<RewardTierRow> {
  final Value<int> position;
  final Value<int> threshold;
  final Value<String> reward;
  final Value<bool> repeatable;
  const RewardTierRowsCompanion({
    this.position = const Value.absent(),
    this.threshold = const Value.absent(),
    this.reward = const Value.absent(),
    this.repeatable = const Value.absent(),
  });
  RewardTierRowsCompanion.insert({
    this.position = const Value.absent(),
    required int threshold,
    required String reward,
    this.repeatable = const Value.absent(),
  }) : threshold = Value(threshold),
       reward = Value(reward);
  static Insertable<RewardTierRow> custom({
    Expression<int>? position,
    Expression<int>? threshold,
    Expression<String>? reward,
    Expression<bool>? repeatable,
  }) {
    return RawValuesInsertable({
      if (position != null) 'position': position,
      if (threshold != null) 'threshold': threshold,
      if (reward != null) 'reward': reward,
      if (repeatable != null) 'repeatable': repeatable,
    });
  }

  RewardTierRowsCompanion copyWith({
    Value<int>? position,
    Value<int>? threshold,
    Value<String>? reward,
    Value<bool>? repeatable,
  }) {
    return RewardTierRowsCompanion(
      position: position ?? this.position,
      threshold: threshold ?? this.threshold,
      reward: reward ?? this.reward,
      repeatable: repeatable ?? this.repeatable,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (threshold.present) {
      map['threshold'] = Variable<int>(threshold.value);
    }
    if (reward.present) {
      map['reward'] = Variable<String>(reward.value);
    }
    if (repeatable.present) {
      map['repeatable'] = Variable<bool>(repeatable.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RewardTierRowsCompanion(')
          ..write('position: $position, ')
          ..write('threshold: $threshold, ')
          ..write('reward: $reward, ')
          ..write('repeatable: $repeatable')
          ..write(')'))
        .toString();
  }
}

class $WeekResultsTable extends WeekResults
    with TableInfo<$WeekResultsTable, WeekResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeekResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _weekStartMeta = const VerificationMeta(
    'weekStart',
  );
  @override
  late final GeneratedColumn<String> weekStart = GeneratedColumn<String>(
    'week_start',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tierIndexMeta = const VerificationMeta(
    'tierIndex',
  );
  @override
  late final GeneratedColumn<int> tierIndex = GeneratedColumn<int>(
    'tier_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rewardMeta = const VerificationMeta('reward');
  @override
  late final GeneratedColumn<String> reward = GeneratedColumn<String>(
    'reward',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [weekStart, tierIndex, reward];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'week_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeekResult> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('week_start')) {
      context.handle(
        _weekStartMeta,
        weekStart.isAcceptableOrUnknown(data['week_start']!, _weekStartMeta),
      );
    } else if (isInserting) {
      context.missing(_weekStartMeta);
    }
    if (data.containsKey('tier_index')) {
      context.handle(
        _tierIndexMeta,
        tierIndex.isAcceptableOrUnknown(data['tier_index']!, _tierIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_tierIndexMeta);
    }
    if (data.containsKey('reward')) {
      context.handle(
        _rewardMeta,
        reward.isAcceptableOrUnknown(data['reward']!, _rewardMeta),
      );
    } else if (isInserting) {
      context.missing(_rewardMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {weekStart};
  @override
  WeekResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeekResult(
      weekStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}week_start'],
      )!,
      tierIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tier_index'],
      )!,
      reward: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reward'],
      )!,
    );
  }

  @override
  $WeekResultsTable createAlias(String alias) {
    return $WeekResultsTable(attachedDatabase, alias);
  }
}

class WeekResult extends DataClass implements Insertable<WeekResult> {
  final String weekStart;
  final int tierIndex;
  final String reward;
  const WeekResult({
    required this.weekStart,
    required this.tierIndex,
    required this.reward,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['week_start'] = Variable<String>(weekStart);
    map['tier_index'] = Variable<int>(tierIndex);
    map['reward'] = Variable<String>(reward);
    return map;
  }

  WeekResultsCompanion toCompanion(bool nullToAbsent) {
    return WeekResultsCompanion(
      weekStart: Value(weekStart),
      tierIndex: Value(tierIndex),
      reward: Value(reward),
    );
  }

  factory WeekResult.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeekResult(
      weekStart: serializer.fromJson<String>(json['weekStart']),
      tierIndex: serializer.fromJson<int>(json['tierIndex']),
      reward: serializer.fromJson<String>(json['reward']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'weekStart': serializer.toJson<String>(weekStart),
      'tierIndex': serializer.toJson<int>(tierIndex),
      'reward': serializer.toJson<String>(reward),
    };
  }

  WeekResult copyWith({String? weekStart, int? tierIndex, String? reward}) =>
      WeekResult(
        weekStart: weekStart ?? this.weekStart,
        tierIndex: tierIndex ?? this.tierIndex,
        reward: reward ?? this.reward,
      );
  WeekResult copyWithCompanion(WeekResultsCompanion data) {
    return WeekResult(
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
      tierIndex: data.tierIndex.present ? data.tierIndex.value : this.tierIndex,
      reward: data.reward.present ? data.reward.value : this.reward,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeekResult(')
          ..write('weekStart: $weekStart, ')
          ..write('tierIndex: $tierIndex, ')
          ..write('reward: $reward')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(weekStart, tierIndex, reward);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeekResult &&
          other.weekStart == this.weekStart &&
          other.tierIndex == this.tierIndex &&
          other.reward == this.reward);
}

class WeekResultsCompanion extends UpdateCompanion<WeekResult> {
  final Value<String> weekStart;
  final Value<int> tierIndex;
  final Value<String> reward;
  final Value<int> rowid;
  const WeekResultsCompanion({
    this.weekStart = const Value.absent(),
    this.tierIndex = const Value.absent(),
    this.reward = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeekResultsCompanion.insert({
    required String weekStart,
    required int tierIndex,
    required String reward,
    this.rowid = const Value.absent(),
  }) : weekStart = Value(weekStart),
       tierIndex = Value(tierIndex),
       reward = Value(reward);
  static Insertable<WeekResult> custom({
    Expression<String>? weekStart,
    Expression<int>? tierIndex,
    Expression<String>? reward,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (weekStart != null) 'week_start': weekStart,
      if (tierIndex != null) 'tier_index': tierIndex,
      if (reward != null) 'reward': reward,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeekResultsCompanion copyWith({
    Value<String>? weekStart,
    Value<int>? tierIndex,
    Value<String>? reward,
    Value<int>? rowid,
  }) {
    return WeekResultsCompanion(
      weekStart: weekStart ?? this.weekStart,
      tierIndex: tierIndex ?? this.tierIndex,
      reward: reward ?? this.reward,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (weekStart.present) {
      map['week_start'] = Variable<String>(weekStart.value);
    }
    if (tierIndex.present) {
      map['tier_index'] = Variable<int>(tierIndex.value);
    }
    if (reward.present) {
      map['reward'] = Variable<String>(reward.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeekResultsCompanion(')
          ..write('weekStart: $weekStart, ')
          ..write('tierIndex: $tierIndex, ')
          ..write('reward: $reward, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettlementStateTable extends SettlementState
    with TableInfo<$SettlementStateTable, SettlementStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettlementStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _lastSettledWeekMeta = const VerificationMeta(
    'lastSettledWeek',
  );
  @override
  late final GeneratedColumn<String> lastSettledWeek = GeneratedColumn<String>(
    'last_settled_week',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, lastSettledWeek];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settlement_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettlementStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('last_settled_week')) {
      context.handle(
        _lastSettledWeekMeta,
        lastSettledWeek.isAcceptableOrUnknown(
          data['last_settled_week']!,
          _lastSettledWeekMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettlementStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettlementStateData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lastSettledWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_settled_week'],
      ),
    );
  }

  @override
  $SettlementStateTable createAlias(String alias) {
    return $SettlementStateTable(attachedDatabase, alias);
  }
}

class SettlementStateData extends DataClass
    implements Insertable<SettlementStateData> {
  final int id;
  final String? lastSettledWeek;
  const SettlementStateData({required this.id, this.lastSettledWeek});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || lastSettledWeek != null) {
      map['last_settled_week'] = Variable<String>(lastSettledWeek);
    }
    return map;
  }

  SettlementStateCompanion toCompanion(bool nullToAbsent) {
    return SettlementStateCompanion(
      id: Value(id),
      lastSettledWeek: lastSettledWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSettledWeek),
    );
  }

  factory SettlementStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettlementStateData(
      id: serializer.fromJson<int>(json['id']),
      lastSettledWeek: serializer.fromJson<String?>(json['lastSettledWeek']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lastSettledWeek': serializer.toJson<String?>(lastSettledWeek),
    };
  }

  SettlementStateData copyWith({
    int? id,
    Value<String?> lastSettledWeek = const Value.absent(),
  }) => SettlementStateData(
    id: id ?? this.id,
    lastSettledWeek: lastSettledWeek.present
        ? lastSettledWeek.value
        : this.lastSettledWeek,
  );
  SettlementStateData copyWithCompanion(SettlementStateCompanion data) {
    return SettlementStateData(
      id: data.id.present ? data.id.value : this.id,
      lastSettledWeek: data.lastSettledWeek.present
          ? data.lastSettledWeek.value
          : this.lastSettledWeek,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettlementStateData(')
          ..write('id: $id, ')
          ..write('lastSettledWeek: $lastSettledWeek')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, lastSettledWeek);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettlementStateData &&
          other.id == this.id &&
          other.lastSettledWeek == this.lastSettledWeek);
}

class SettlementStateCompanion extends UpdateCompanion<SettlementStateData> {
  final Value<int> id;
  final Value<String?> lastSettledWeek;
  const SettlementStateCompanion({
    this.id = const Value.absent(),
    this.lastSettledWeek = const Value.absent(),
  });
  SettlementStateCompanion.insert({
    this.id = const Value.absent(),
    this.lastSettledWeek = const Value.absent(),
  });
  static Insertable<SettlementStateData> custom({
    Expression<int>? id,
    Expression<String>? lastSettledWeek,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastSettledWeek != null) 'last_settled_week': lastSettledWeek,
    });
  }

  SettlementStateCompanion copyWith({
    Value<int>? id,
    Value<String?>? lastSettledWeek,
  }) {
    return SettlementStateCompanion(
      id: id ?? this.id,
      lastSettledWeek: lastSettledWeek ?? this.lastSettledWeek,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lastSettledWeek.present) {
      map['last_settled_week'] = Variable<String>(lastSettledWeek.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettlementStateCompanion(')
          ..write('id: $id, ')
          ..write('lastSettledWeek: $lastSettledWeek')
          ..write(')'))
        .toString();
  }
}

abstract class _$TokenDatabase extends GeneratedDatabase {
  _$TokenDatabase(QueryExecutor e) : super(e);
  $TokenDatabaseManager get managers => $TokenDatabaseManager(this);
  late final $TemplateSettingsTable templateSettings = $TemplateSettingsTable(
    this,
  );
  late final $TaskRowsTable taskRows = $TaskRowsTable(this);
  late final $CompletionsTable completions = $CompletionsTable(this);
  late final $WeekClaimsTable weekClaims = $WeekClaimsTable(this);
  late final $RewardTierRowsTable rewardTierRows = $RewardTierRowsTable(this);
  late final $WeekResultsTable weekResults = $WeekResultsTable(this);
  late final $SettlementStateTable settlementState = $SettlementStateTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    templateSettings,
    taskRows,
    completions,
    weekClaims,
    rewardTierRows,
    weekResults,
    settlementState,
  ];
}

typedef $$TemplateSettingsTableCreateCompanionBuilder =
    TemplateSettingsCompanion Function({
      Value<int> id,
      Value<int> daysPerWeek,
      Value<int> weekStartDay,
      Value<int> weeklyGoal,
      Value<String> reward,
    });
typedef $$TemplateSettingsTableUpdateCompanionBuilder =
    TemplateSettingsCompanion Function({
      Value<int> id,
      Value<int> daysPerWeek,
      Value<int> weekStartDay,
      Value<int> weeklyGoal,
      Value<String> reward,
    });

class $$TemplateSettingsTableFilterComposer
    extends Composer<_$TokenDatabase, $TemplateSettingsTable> {
  $$TemplateSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get daysPerWeek => $composableBuilder(
    column: $table.daysPerWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekStartDay => $composableBuilder(
    column: $table.weekStartDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weeklyGoal => $composableBuilder(
    column: $table.weeklyGoal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reward => $composableBuilder(
    column: $table.reward,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TemplateSettingsTableOrderingComposer
    extends Composer<_$TokenDatabase, $TemplateSettingsTable> {
  $$TemplateSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get daysPerWeek => $composableBuilder(
    column: $table.daysPerWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekStartDay => $composableBuilder(
    column: $table.weekStartDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weeklyGoal => $composableBuilder(
    column: $table.weeklyGoal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reward => $composableBuilder(
    column: $table.reward,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TemplateSettingsTableAnnotationComposer
    extends Composer<_$TokenDatabase, $TemplateSettingsTable> {
  $$TemplateSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get daysPerWeek => $composableBuilder(
    column: $table.daysPerWeek,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weekStartDay => $composableBuilder(
    column: $table.weekStartDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weeklyGoal => $composableBuilder(
    column: $table.weeklyGoal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reward =>
      $composableBuilder(column: $table.reward, builder: (column) => column);
}

class $$TemplateSettingsTableTableManager
    extends
        RootTableManager<
          _$TokenDatabase,
          $TemplateSettingsTable,
          TemplateSetting,
          $$TemplateSettingsTableFilterComposer,
          $$TemplateSettingsTableOrderingComposer,
          $$TemplateSettingsTableAnnotationComposer,
          $$TemplateSettingsTableCreateCompanionBuilder,
          $$TemplateSettingsTableUpdateCompanionBuilder,
          (
            TemplateSetting,
            BaseReferences<
              _$TokenDatabase,
              $TemplateSettingsTable,
              TemplateSetting
            >,
          ),
          TemplateSetting,
          PrefetchHooks Function()
        > {
  $$TemplateSettingsTableTableManager(
    _$TokenDatabase db,
    $TemplateSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TemplateSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TemplateSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TemplateSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> daysPerWeek = const Value.absent(),
                Value<int> weekStartDay = const Value.absent(),
                Value<int> weeklyGoal = const Value.absent(),
                Value<String> reward = const Value.absent(),
              }) => TemplateSettingsCompanion(
                id: id,
                daysPerWeek: daysPerWeek,
                weekStartDay: weekStartDay,
                weeklyGoal: weeklyGoal,
                reward: reward,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> daysPerWeek = const Value.absent(),
                Value<int> weekStartDay = const Value.absent(),
                Value<int> weeklyGoal = const Value.absent(),
                Value<String> reward = const Value.absent(),
              }) => TemplateSettingsCompanion.insert(
                id: id,
                daysPerWeek: daysPerWeek,
                weekStartDay: weekStartDay,
                weeklyGoal: weeklyGoal,
                reward: reward,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TemplateSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$TokenDatabase,
      $TemplateSettingsTable,
      TemplateSetting,
      $$TemplateSettingsTableFilterComposer,
      $$TemplateSettingsTableOrderingComposer,
      $$TemplateSettingsTableAnnotationComposer,
      $$TemplateSettingsTableCreateCompanionBuilder,
      $$TemplateSettingsTableUpdateCompanionBuilder,
      (
        TemplateSetting,
        BaseReferences<
          _$TokenDatabase,
          $TemplateSettingsTable,
          TemplateSetting
        >,
      ),
      TemplateSetting,
      PrefetchHooks Function()
    >;
typedef $$TaskRowsTableCreateCompanionBuilder =
    TaskRowsCompanion Function({
      required String id,
      required String name,
      required int position,
      Value<int?> minPerWeek,
      Value<int?> maxPerWeek,
      Value<int> rowid,
    });
typedef $$TaskRowsTableUpdateCompanionBuilder =
    TaskRowsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> position,
      Value<int?> minPerWeek,
      Value<int?> maxPerWeek,
      Value<int> rowid,
    });

class $$TaskRowsTableFilterComposer
    extends Composer<_$TokenDatabase, $TaskRowsTable> {
  $$TaskRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minPerWeek => $composableBuilder(
    column: $table.minPerWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxPerWeek => $composableBuilder(
    column: $table.maxPerWeek,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaskRowsTableOrderingComposer
    extends Composer<_$TokenDatabase, $TaskRowsTable> {
  $$TaskRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minPerWeek => $composableBuilder(
    column: $table.minPerWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxPerWeek => $composableBuilder(
    column: $table.maxPerWeek,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaskRowsTableAnnotationComposer
    extends Composer<_$TokenDatabase, $TaskRowsTable> {
  $$TaskRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get minPerWeek => $composableBuilder(
    column: $table.minPerWeek,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxPerWeek => $composableBuilder(
    column: $table.maxPerWeek,
    builder: (column) => column,
  );
}

class $$TaskRowsTableTableManager
    extends
        RootTableManager<
          _$TokenDatabase,
          $TaskRowsTable,
          TaskRow,
          $$TaskRowsTableFilterComposer,
          $$TaskRowsTableOrderingComposer,
          $$TaskRowsTableAnnotationComposer,
          $$TaskRowsTableCreateCompanionBuilder,
          $$TaskRowsTableUpdateCompanionBuilder,
          (TaskRow, BaseReferences<_$TokenDatabase, $TaskRowsTable, TaskRow>),
          TaskRow,
          PrefetchHooks Function()
        > {
  $$TaskRowsTableTableManager(_$TokenDatabase db, $TaskRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int?> minPerWeek = const Value.absent(),
                Value<int?> maxPerWeek = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskRowsCompanion(
                id: id,
                name: name,
                position: position,
                minPerWeek: minPerWeek,
                maxPerWeek: maxPerWeek,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int position,
                Value<int?> minPerWeek = const Value.absent(),
                Value<int?> maxPerWeek = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskRowsCompanion.insert(
                id: id,
                name: name,
                position: position,
                minPerWeek: minPerWeek,
                maxPerWeek: maxPerWeek,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaskRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$TokenDatabase,
      $TaskRowsTable,
      TaskRow,
      $$TaskRowsTableFilterComposer,
      $$TaskRowsTableOrderingComposer,
      $$TaskRowsTableAnnotationComposer,
      $$TaskRowsTableCreateCompanionBuilder,
      $$TaskRowsTableUpdateCompanionBuilder,
      (TaskRow, BaseReferences<_$TokenDatabase, $TaskRowsTable, TaskRow>),
      TaskRow,
      PrefetchHooks Function()
    >;
typedef $$CompletionsTableCreateCompanionBuilder =
    CompletionsCompanion Function({
      required String day,
      required String taskId,
      Value<int> rowid,
    });
typedef $$CompletionsTableUpdateCompanionBuilder =
    CompletionsCompanion Function({
      Value<String> day,
      Value<String> taskId,
      Value<int> rowid,
    });

class $$CompletionsTableFilterComposer
    extends Composer<_$TokenDatabase, $CompletionsTable> {
  $$CompletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CompletionsTableOrderingComposer
    extends Composer<_$TokenDatabase, $CompletionsTable> {
  $$CompletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompletionsTableAnnotationComposer
    extends Composer<_$TokenDatabase, $CompletionsTable> {
  $$CompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);
}

class $$CompletionsTableTableManager
    extends
        RootTableManager<
          _$TokenDatabase,
          $CompletionsTable,
          Completion,
          $$CompletionsTableFilterComposer,
          $$CompletionsTableOrderingComposer,
          $$CompletionsTableAnnotationComposer,
          $$CompletionsTableCreateCompanionBuilder,
          $$CompletionsTableUpdateCompanionBuilder,
          (
            Completion,
            BaseReferences<_$TokenDatabase, $CompletionsTable, Completion>,
          ),
          Completion,
          PrefetchHooks Function()
        > {
  $$CompletionsTableTableManager(_$TokenDatabase db, $CompletionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompletionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> day = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  CompletionsCompanion(day: day, taskId: taskId, rowid: rowid),
          createCompanionCallback:
              ({
                required String day,
                required String taskId,
                Value<int> rowid = const Value.absent(),
              }) => CompletionsCompanion.insert(
                day: day,
                taskId: taskId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$TokenDatabase,
      $CompletionsTable,
      Completion,
      $$CompletionsTableFilterComposer,
      $$CompletionsTableOrderingComposer,
      $$CompletionsTableAnnotationComposer,
      $$CompletionsTableCreateCompanionBuilder,
      $$CompletionsTableUpdateCompanionBuilder,
      (
        Completion,
        BaseReferences<_$TokenDatabase, $CompletionsTable, Completion>,
      ),
      Completion,
      PrefetchHooks Function()
    >;
typedef $$WeekClaimsTableCreateCompanionBuilder =
    WeekClaimsCompanion Function({required String weekStart, Value<int> rowid});
typedef $$WeekClaimsTableUpdateCompanionBuilder =
    WeekClaimsCompanion Function({Value<String> weekStart, Value<int> rowid});

class $$WeekClaimsTableFilterComposer
    extends Composer<_$TokenDatabase, $WeekClaimsTable> {
  $$WeekClaimsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeekClaimsTableOrderingComposer
    extends Composer<_$TokenDatabase, $WeekClaimsTable> {
  $$WeekClaimsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeekClaimsTableAnnotationComposer
    extends Composer<_$TokenDatabase, $WeekClaimsTable> {
  $$WeekClaimsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => column);
}

class $$WeekClaimsTableTableManager
    extends
        RootTableManager<
          _$TokenDatabase,
          $WeekClaimsTable,
          WeekClaim,
          $$WeekClaimsTableFilterComposer,
          $$WeekClaimsTableOrderingComposer,
          $$WeekClaimsTableAnnotationComposer,
          $$WeekClaimsTableCreateCompanionBuilder,
          $$WeekClaimsTableUpdateCompanionBuilder,
          (
            WeekClaim,
            BaseReferences<_$TokenDatabase, $WeekClaimsTable, WeekClaim>,
          ),
          WeekClaim,
          PrefetchHooks Function()
        > {
  $$WeekClaimsTableTableManager(_$TokenDatabase db, $WeekClaimsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeekClaimsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeekClaimsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeekClaimsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> weekStart = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeekClaimsCompanion(weekStart: weekStart, rowid: rowid),
          createCompanionCallback:
              ({
                required String weekStart,
                Value<int> rowid = const Value.absent(),
              }) => WeekClaimsCompanion.insert(
                weekStart: weekStart,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeekClaimsTableProcessedTableManager =
    ProcessedTableManager<
      _$TokenDatabase,
      $WeekClaimsTable,
      WeekClaim,
      $$WeekClaimsTableFilterComposer,
      $$WeekClaimsTableOrderingComposer,
      $$WeekClaimsTableAnnotationComposer,
      $$WeekClaimsTableCreateCompanionBuilder,
      $$WeekClaimsTableUpdateCompanionBuilder,
      (WeekClaim, BaseReferences<_$TokenDatabase, $WeekClaimsTable, WeekClaim>),
      WeekClaim,
      PrefetchHooks Function()
    >;
typedef $$RewardTierRowsTableCreateCompanionBuilder =
    RewardTierRowsCompanion Function({
      Value<int> position,
      required int threshold,
      required String reward,
      Value<bool> repeatable,
    });
typedef $$RewardTierRowsTableUpdateCompanionBuilder =
    RewardTierRowsCompanion Function({
      Value<int> position,
      Value<int> threshold,
      Value<String> reward,
      Value<bool> repeatable,
    });

class $$RewardTierRowsTableFilterComposer
    extends Composer<_$TokenDatabase, $RewardTierRowsTable> {
  $$RewardTierRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get threshold => $composableBuilder(
    column: $table.threshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reward => $composableBuilder(
    column: $table.reward,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get repeatable => $composableBuilder(
    column: $table.repeatable,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RewardTierRowsTableOrderingComposer
    extends Composer<_$TokenDatabase, $RewardTierRowsTable> {
  $$RewardTierRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get threshold => $composableBuilder(
    column: $table.threshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reward => $composableBuilder(
    column: $table.reward,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get repeatable => $composableBuilder(
    column: $table.repeatable,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RewardTierRowsTableAnnotationComposer
    extends Composer<_$TokenDatabase, $RewardTierRowsTable> {
  $$RewardTierRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get threshold =>
      $composableBuilder(column: $table.threshold, builder: (column) => column);

  GeneratedColumn<String> get reward =>
      $composableBuilder(column: $table.reward, builder: (column) => column);

  GeneratedColumn<bool> get repeatable => $composableBuilder(
    column: $table.repeatable,
    builder: (column) => column,
  );
}

class $$RewardTierRowsTableTableManager
    extends
        RootTableManager<
          _$TokenDatabase,
          $RewardTierRowsTable,
          RewardTierRow,
          $$RewardTierRowsTableFilterComposer,
          $$RewardTierRowsTableOrderingComposer,
          $$RewardTierRowsTableAnnotationComposer,
          $$RewardTierRowsTableCreateCompanionBuilder,
          $$RewardTierRowsTableUpdateCompanionBuilder,
          (
            RewardTierRow,
            BaseReferences<
              _$TokenDatabase,
              $RewardTierRowsTable,
              RewardTierRow
            >,
          ),
          RewardTierRow,
          PrefetchHooks Function()
        > {
  $$RewardTierRowsTableTableManager(
    _$TokenDatabase db,
    $RewardTierRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RewardTierRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RewardTierRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RewardTierRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> position = const Value.absent(),
                Value<int> threshold = const Value.absent(),
                Value<String> reward = const Value.absent(),
                Value<bool> repeatable = const Value.absent(),
              }) => RewardTierRowsCompanion(
                position: position,
                threshold: threshold,
                reward: reward,
                repeatable: repeatable,
              ),
          createCompanionCallback:
              ({
                Value<int> position = const Value.absent(),
                required int threshold,
                required String reward,
                Value<bool> repeatable = const Value.absent(),
              }) => RewardTierRowsCompanion.insert(
                position: position,
                threshold: threshold,
                reward: reward,
                repeatable: repeatable,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RewardTierRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$TokenDatabase,
      $RewardTierRowsTable,
      RewardTierRow,
      $$RewardTierRowsTableFilterComposer,
      $$RewardTierRowsTableOrderingComposer,
      $$RewardTierRowsTableAnnotationComposer,
      $$RewardTierRowsTableCreateCompanionBuilder,
      $$RewardTierRowsTableUpdateCompanionBuilder,
      (
        RewardTierRow,
        BaseReferences<_$TokenDatabase, $RewardTierRowsTable, RewardTierRow>,
      ),
      RewardTierRow,
      PrefetchHooks Function()
    >;
typedef $$WeekResultsTableCreateCompanionBuilder =
    WeekResultsCompanion Function({
      required String weekStart,
      required int tierIndex,
      required String reward,
      Value<int> rowid,
    });
typedef $$WeekResultsTableUpdateCompanionBuilder =
    WeekResultsCompanion Function({
      Value<String> weekStart,
      Value<int> tierIndex,
      Value<String> reward,
      Value<int> rowid,
    });

class $$WeekResultsTableFilterComposer
    extends Composer<_$TokenDatabase, $WeekResultsTable> {
  $$WeekResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tierIndex => $composableBuilder(
    column: $table.tierIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reward => $composableBuilder(
    column: $table.reward,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeekResultsTableOrderingComposer
    extends Composer<_$TokenDatabase, $WeekResultsTable> {
  $$WeekResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tierIndex => $composableBuilder(
    column: $table.tierIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reward => $composableBuilder(
    column: $table.reward,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeekResultsTableAnnotationComposer
    extends Composer<_$TokenDatabase, $WeekResultsTable> {
  $$WeekResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => column);

  GeneratedColumn<int> get tierIndex =>
      $composableBuilder(column: $table.tierIndex, builder: (column) => column);

  GeneratedColumn<String> get reward =>
      $composableBuilder(column: $table.reward, builder: (column) => column);
}

class $$WeekResultsTableTableManager
    extends
        RootTableManager<
          _$TokenDatabase,
          $WeekResultsTable,
          WeekResult,
          $$WeekResultsTableFilterComposer,
          $$WeekResultsTableOrderingComposer,
          $$WeekResultsTableAnnotationComposer,
          $$WeekResultsTableCreateCompanionBuilder,
          $$WeekResultsTableUpdateCompanionBuilder,
          (
            WeekResult,
            BaseReferences<_$TokenDatabase, $WeekResultsTable, WeekResult>,
          ),
          WeekResult,
          PrefetchHooks Function()
        > {
  $$WeekResultsTableTableManager(_$TokenDatabase db, $WeekResultsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeekResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeekResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeekResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> weekStart = const Value.absent(),
                Value<int> tierIndex = const Value.absent(),
                Value<String> reward = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeekResultsCompanion(
                weekStart: weekStart,
                tierIndex: tierIndex,
                reward: reward,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String weekStart,
                required int tierIndex,
                required String reward,
                Value<int> rowid = const Value.absent(),
              }) => WeekResultsCompanion.insert(
                weekStart: weekStart,
                tierIndex: tierIndex,
                reward: reward,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeekResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$TokenDatabase,
      $WeekResultsTable,
      WeekResult,
      $$WeekResultsTableFilterComposer,
      $$WeekResultsTableOrderingComposer,
      $$WeekResultsTableAnnotationComposer,
      $$WeekResultsTableCreateCompanionBuilder,
      $$WeekResultsTableUpdateCompanionBuilder,
      (
        WeekResult,
        BaseReferences<_$TokenDatabase, $WeekResultsTable, WeekResult>,
      ),
      WeekResult,
      PrefetchHooks Function()
    >;
typedef $$SettlementStateTableCreateCompanionBuilder =
    SettlementStateCompanion Function({
      Value<int> id,
      Value<String?> lastSettledWeek,
    });
typedef $$SettlementStateTableUpdateCompanionBuilder =
    SettlementStateCompanion Function({
      Value<int> id,
      Value<String?> lastSettledWeek,
    });

class $$SettlementStateTableFilterComposer
    extends Composer<_$TokenDatabase, $SettlementStateTable> {
  $$SettlementStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSettledWeek => $composableBuilder(
    column: $table.lastSettledWeek,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettlementStateTableOrderingComposer
    extends Composer<_$TokenDatabase, $SettlementStateTable> {
  $$SettlementStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSettledWeek => $composableBuilder(
    column: $table.lastSettledWeek,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettlementStateTableAnnotationComposer
    extends Composer<_$TokenDatabase, $SettlementStateTable> {
  $$SettlementStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lastSettledWeek => $composableBuilder(
    column: $table.lastSettledWeek,
    builder: (column) => column,
  );
}

class $$SettlementStateTableTableManager
    extends
        RootTableManager<
          _$TokenDatabase,
          $SettlementStateTable,
          SettlementStateData,
          $$SettlementStateTableFilterComposer,
          $$SettlementStateTableOrderingComposer,
          $$SettlementStateTableAnnotationComposer,
          $$SettlementStateTableCreateCompanionBuilder,
          $$SettlementStateTableUpdateCompanionBuilder,
          (
            SettlementStateData,
            BaseReferences<
              _$TokenDatabase,
              $SettlementStateTable,
              SettlementStateData
            >,
          ),
          SettlementStateData,
          PrefetchHooks Function()
        > {
  $$SettlementStateTableTableManager(
    _$TokenDatabase db,
    $SettlementStateTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettlementStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettlementStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettlementStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> lastSettledWeek = const Value.absent(),
              }) => SettlementStateCompanion(
                id: id,
                lastSettledWeek: lastSettledWeek,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> lastSettledWeek = const Value.absent(),
              }) => SettlementStateCompanion.insert(
                id: id,
                lastSettledWeek: lastSettledWeek,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettlementStateTableProcessedTableManager =
    ProcessedTableManager<
      _$TokenDatabase,
      $SettlementStateTable,
      SettlementStateData,
      $$SettlementStateTableFilterComposer,
      $$SettlementStateTableOrderingComposer,
      $$SettlementStateTableAnnotationComposer,
      $$SettlementStateTableCreateCompanionBuilder,
      $$SettlementStateTableUpdateCompanionBuilder,
      (
        SettlementStateData,
        BaseReferences<
          _$TokenDatabase,
          $SettlementStateTable,
          SettlementStateData
        >,
      ),
      SettlementStateData,
      PrefetchHooks Function()
    >;

class $TokenDatabaseManager {
  final _$TokenDatabase _db;
  $TokenDatabaseManager(this._db);
  $$TemplateSettingsTableTableManager get templateSettings =>
      $$TemplateSettingsTableTableManager(_db, _db.templateSettings);
  $$TaskRowsTableTableManager get taskRows =>
      $$TaskRowsTableTableManager(_db, _db.taskRows);
  $$CompletionsTableTableManager get completions =>
      $$CompletionsTableTableManager(_db, _db.completions);
  $$WeekClaimsTableTableManager get weekClaims =>
      $$WeekClaimsTableTableManager(_db, _db.weekClaims);
  $$RewardTierRowsTableTableManager get rewardTierRows =>
      $$RewardTierRowsTableTableManager(_db, _db.rewardTierRows);
  $$WeekResultsTableTableManager get weekResults =>
      $$WeekResultsTableTableManager(_db, _db.weekResults);
  $$SettlementStateTableTableManager get settlementState =>
      $$SettlementStateTableTableManager(_db, _db.settlementState);
}
