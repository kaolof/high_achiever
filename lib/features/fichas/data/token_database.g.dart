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
  @override
  List<GeneratedColumn> get $columns => [id, name, position];
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
  const TaskRow({required this.id, required this.name, required this.position});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['position'] = Variable<int>(position);
    return map;
  }

  TaskRowsCompanion toCompanion(bool nullToAbsent) {
    return TaskRowsCompanion(
      id: Value(id),
      name: Value(name),
      position: Value(position),
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
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'position': serializer.toJson<int>(position),
    };
  }

  TaskRow copyWith({String? id, String? name, int? position}) => TaskRow(
    id: id ?? this.id,
    name: name ?? this.name,
    position: position ?? this.position,
  );
  TaskRow copyWithCompanion(TaskRowsCompanion data) {
    return TaskRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.position == this.position);
}

class TaskRowsCompanion extends UpdateCompanion<TaskRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> position;
  final Value<int> rowid;
  const TaskRowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskRowsCompanion.insert({
    required String id,
    required String name,
    required int position,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       position = Value(position);
  static Insertable<TaskRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return TaskRowsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
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

abstract class _$TokenDatabase extends GeneratedDatabase {
  _$TokenDatabase(QueryExecutor e) : super(e);
  $TokenDatabaseManager get managers => $TokenDatabaseManager(this);
  late final $TemplateSettingsTable templateSettings = $TemplateSettingsTable(
    this,
  );
  late final $TaskRowsTable taskRows = $TaskRowsTable(this);
  late final $CompletionsTable completions = $CompletionsTable(this);
  late final $WeekClaimsTable weekClaims = $WeekClaimsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    templateSettings,
    taskRows,
    completions,
    weekClaims,
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
      Value<int> rowid,
    });
typedef $$TaskRowsTableUpdateCompanionBuilder =
    TaskRowsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> position,
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
                Value<int> rowid = const Value.absent(),
              }) => TaskRowsCompanion(
                id: id,
                name: name,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => TaskRowsCompanion.insert(
                id: id,
                name: name,
                position: position,
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
}
