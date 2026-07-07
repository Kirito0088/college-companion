// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SemestersTable extends Semesters
    with TableInfo<$SemestersTable, SemesterEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SemestersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdOfflineMeta = const VerificationMeta(
    'createdOffline',
  );
  @override
  late final GeneratedColumn<bool> createdOffline = GeneratedColumn<bool>(
    'created_offline',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("created_offline" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
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
  static const VerificationMeta _workingDaysMeta = const VerificationMeta(
    'workingDays',
  );
  @override
  late final GeneratedColumn<String> workingDays = GeneratedColumn<String>(
    'working_days',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCurrentMeta = const VerificationMeta(
    'isCurrent',
  );
  @override
  late final GeneratedColumn<bool> isCurrent = GeneratedColumn<bool>(
    'is_current',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_current" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    syncStatus,
    syncVersion,
    createdOffline,
    lastSyncedAt,
    id,
    userId,
    name,
    workingDays,
    isCurrent,
    isArchived,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'semesters';
  @override
  VerificationContext validateIntegrity(
    Insertable<SemesterEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    if (data.containsKey('created_offline')) {
      context.handle(
        _createdOfflineMeta,
        createdOffline.isAcceptableOrUnknown(
          data['created_offline']!,
          _createdOfflineMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('working_days')) {
      context.handle(
        _workingDaysMeta,
        workingDays.isAcceptableOrUnknown(
          data['working_days']!,
          _workingDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workingDaysMeta);
    }
    if (data.containsKey('is_current')) {
      context.handle(
        _isCurrentMeta,
        isCurrent.isAcceptableOrUnknown(data['is_current']!, _isCurrentMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SemesterEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SemesterEntity(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
      createdOffline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}created_offline'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      workingDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}working_days'],
      )!,
      isCurrent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_current'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $SemestersTable createAlias(String alias) {
    return $SemestersTable(attachedDatabase, alias);
  }
}

class SemesterEntity extends DataClass implements Insertable<SemesterEntity> {
  /// UTC creation timestamp.
  final DateTime createdAt;

  /// UTC last-modified timestamp — sync bookkeeping; bumped on every local
  /// write. Repositories set this explicitly (no local auto-touch trigger,
  /// to keep DateTime text-format consistency with Drift's reader).
  final DateTime updatedAt;

  /// Per-row sync state: `pending`, `synced`, or `failed`.
  final String syncStatus;

  /// Bumped on each local change; aids conflict detection (Phase 5).
  final int syncVersion;

  /// Whether this row was created while offline (offline-first origin).
  final bool createdOffline;

  /// Timestamp of the last successful cloud push. NULL if never synced
  /// (spec §11 "Sync timestamp").
  final DateTime? lastSyncedAt;

  /// UUID primary key.
  final String id;

  /// User ID (Supabase Auth UID). Denormalized for RLS-like filtering.
  final String userId;

  /// User-defined semester label (e.g., "Semester 5", "Fall 2026").
  final String name;

  /// Array of working days (0=Monday, 6=Sunday). Matches timetable.day_of_week.
  /// Stored as JSON string since Drift has no native array support.
  final String workingDays;

  /// Whether this is the active semester.
  final bool isCurrent;

  /// Whether this semester has been archived.
  final bool isArchived;

  /// Soft delete: NULL = active, timestamp = deleted.
  final DateTime? deletedAt;
  const SemesterEntity({
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.syncVersion,
    required this.createdOffline,
    this.lastSyncedAt,
    required this.id,
    required this.userId,
    required this.name,
    required this.workingDays,
    required this.isCurrent,
    required this.isArchived,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    map['sync_version'] = Variable<int>(syncVersion);
    map['created_offline'] = Variable<bool>(createdOffline);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['working_days'] = Variable<String>(workingDays);
    map['is_current'] = Variable<bool>(isCurrent);
    map['is_archived'] = Variable<bool>(isArchived);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  SemestersCompanion toCompanion(bool nullToAbsent) {
    return SemestersCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      syncVersion: Value(syncVersion),
      createdOffline: Value(createdOffline),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      workingDays: Value(workingDays),
      isCurrent: Value(isCurrent),
      isArchived: Value(isArchived),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory SemesterEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SemesterEntity(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
      createdOffline: serializer.fromJson<bool>(json['createdOffline']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      workingDays: serializer.fromJson<String>(json['workingDays']),
      isCurrent: serializer.fromJson<bool>(json['isCurrent']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncVersion': serializer.toJson<int>(syncVersion),
      'createdOffline': serializer.toJson<bool>(createdOffline),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'workingDays': serializer.toJson<String>(workingDays),
      'isCurrent': serializer.toJson<bool>(isCurrent),
      'isArchived': serializer.toJson<bool>(isArchived),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  SemesterEntity copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    int? syncVersion,
    bool? createdOffline,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    String? id,
    String? userId,
    String? name,
    String? workingDays,
    bool? isCurrent,
    bool? isArchived,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => SemesterEntity(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    syncVersion: syncVersion ?? this.syncVersion,
    createdOffline: createdOffline ?? this.createdOffline,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    workingDays: workingDays ?? this.workingDays,
    isCurrent: isCurrent ?? this.isCurrent,
    isArchived: isArchived ?? this.isArchived,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  SemesterEntity copyWithCompanion(SemestersCompanion data) {
    return SemesterEntity(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
      createdOffline: data.createdOffline.present
          ? data.createdOffline.value
          : this.createdOffline,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      workingDays: data.workingDays.present
          ? data.workingDays.value
          : this.workingDays,
      isCurrent: data.isCurrent.present ? data.isCurrent.value : this.isCurrent,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SemesterEntity(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('createdOffline: $createdOffline, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('workingDays: $workingDays, ')
          ..write('isCurrent: $isCurrent, ')
          ..write('isArchived: $isArchived, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    syncStatus,
    syncVersion,
    createdOffline,
    lastSyncedAt,
    id,
    userId,
    name,
    workingDays,
    isCurrent,
    isArchived,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SemesterEntity &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.syncVersion == this.syncVersion &&
          other.createdOffline == this.createdOffline &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.workingDays == this.workingDays &&
          other.isCurrent == this.isCurrent &&
          other.isArchived == this.isArchived &&
          other.deletedAt == this.deletedAt);
}

class SemestersCompanion extends UpdateCompanion<SemesterEntity> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> syncVersion;
  final Value<bool> createdOffline;
  final Value<DateTime?> lastSyncedAt;
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String> workingDays;
  final Value<bool> isCurrent;
  final Value<bool> isArchived;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const SemestersCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.createdOffline = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.workingDays = const Value.absent(),
    this.isCurrent = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SemestersCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.createdOffline = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    required String id,
    required String userId,
    required String name,
    required String workingDays,
    this.isCurrent = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       workingDays = Value(workingDays);
  static Insertable<SemesterEntity> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? syncVersion,
    Expression<bool>? createdOffline,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? workingDays,
    Expression<bool>? isCurrent,
    Expression<bool>? isArchived,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (createdOffline != null) 'created_offline': createdOffline,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (workingDays != null) 'working_days': workingDays,
      if (isCurrent != null) 'is_current': isCurrent,
      if (isArchived != null) 'is_archived': isArchived,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SemestersCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncStatus,
    Value<int>? syncVersion,
    Value<bool>? createdOffline,
    Value<DateTime?>? lastSyncedAt,
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<String>? workingDays,
    Value<bool>? isCurrent,
    Value<bool>? isArchived,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return SemestersCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncVersion: syncVersion ?? this.syncVersion,
      createdOffline: createdOffline ?? this.createdOffline,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      workingDays: workingDays ?? this.workingDays,
      isCurrent: isCurrent ?? this.isCurrent,
      isArchived: isArchived ?? this.isArchived,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (createdOffline.present) {
      map['created_offline'] = Variable<bool>(createdOffline.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (workingDays.present) {
      map['working_days'] = Variable<String>(workingDays.value);
    }
    if (isCurrent.present) {
      map['is_current'] = Variable<bool>(isCurrent.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SemestersCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('createdOffline: $createdOffline, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('workingDays: $workingDays, ')
          ..write('isCurrent: $isCurrent, ')
          ..write('isArchived: $isArchived, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubjectsTable extends Subjects
    with TableInfo<$SubjectsTable, SubjectEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdOfflineMeta = const VerificationMeta(
    'createdOffline',
  );
  @override
  late final GeneratedColumn<bool> createdOffline = GeneratedColumn<bool>(
    'created_offline',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("created_offline" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _semesterIdMeta = const VerificationMeta(
    'semesterId',
  );
  @override
  late final GeneratedColumn<String> semesterId = GeneratedColumn<String>(
    'semester_id',
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
  static const VerificationMeta _facultyMeta = const VerificationMeta(
    'faculty',
  );
  @override
  late final GeneratedColumn<String> faculty = GeneratedColumn<String>(
    'faculty',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('theory'),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    syncStatus,
    syncVersion,
    createdOffline,
    lastSyncedAt,
    id,
    userId,
    semesterId,
    name,
    faculty,
    type,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subjects';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubjectEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    if (data.containsKey('created_offline')) {
      context.handle(
        _createdOfflineMeta,
        createdOffline.isAcceptableOrUnknown(
          data['created_offline']!,
          _createdOfflineMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('semester_id')) {
      context.handle(
        _semesterIdMeta,
        semesterId.isAcceptableOrUnknown(data['semester_id']!, _semesterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_semesterIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('faculty')) {
      context.handle(
        _facultyMeta,
        faculty.isAcceptableOrUnknown(data['faculty']!, _facultyMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {userId, semesterId, name},
  ];
  @override
  SubjectEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubjectEntity(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
      createdOffline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}created_offline'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      semesterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}semester_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      faculty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}faculty'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $SubjectsTable createAlias(String alias) {
    return $SubjectsTable(attachedDatabase, alias);
  }
}

class SubjectEntity extends DataClass implements Insertable<SubjectEntity> {
  /// UTC creation timestamp.
  final DateTime createdAt;

  /// UTC last-modified timestamp — sync bookkeeping; bumped on every local
  /// write. Repositories set this explicitly (no local auto-touch trigger,
  /// to keep DateTime text-format consistency with Drift's reader).
  final DateTime updatedAt;

  /// Per-row sync state: `pending`, `synced`, or `failed`.
  final String syncStatus;

  /// Bumped on each local change; aids conflict detection (Phase 5).
  final int syncVersion;

  /// Whether this row was created while offline (offline-first origin).
  final bool createdOffline;

  /// Timestamp of the last successful cloud push. NULL if never synced
  /// (spec §11 "Sync timestamp").
  final DateTime? lastSyncedAt;

  /// UUID primary key.
  final String id;

  /// User ID (Supabase Auth UID). Denormalized for filtering.
  final String userId;

  /// Parent semester ID. Cascade deletes all subjects when semester is removed.
  final String semesterId;

  /// Subject name (e.g., "Data Structures", "Physics Lab").
  final String name;

  /// Faculty/professor name. Nullable.
  final String? faculty;

  /// Subject type: theory, practical, or tutorial. Defaults to 'theory'.
  final String type;

  /// Soft delete: NULL = active, timestamp = deleted.
  final DateTime? deletedAt;
  const SubjectEntity({
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.syncVersion,
    required this.createdOffline,
    this.lastSyncedAt,
    required this.id,
    required this.userId,
    required this.semesterId,
    required this.name,
    this.faculty,
    required this.type,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    map['sync_version'] = Variable<int>(syncVersion);
    map['created_offline'] = Variable<bool>(createdOffline);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['semester_id'] = Variable<String>(semesterId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || faculty != null) {
      map['faculty'] = Variable<String>(faculty);
    }
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  SubjectsCompanion toCompanion(bool nullToAbsent) {
    return SubjectsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      syncVersion: Value(syncVersion),
      createdOffline: Value(createdOffline),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      id: Value(id),
      userId: Value(userId),
      semesterId: Value(semesterId),
      name: Value(name),
      faculty: faculty == null && nullToAbsent
          ? const Value.absent()
          : Value(faculty),
      type: Value(type),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory SubjectEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubjectEntity(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
      createdOffline: serializer.fromJson<bool>(json['createdOffline']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      semesterId: serializer.fromJson<String>(json['semesterId']),
      name: serializer.fromJson<String>(json['name']),
      faculty: serializer.fromJson<String?>(json['faculty']),
      type: serializer.fromJson<String>(json['type']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncVersion': serializer.toJson<int>(syncVersion),
      'createdOffline': serializer.toJson<bool>(createdOffline),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'semesterId': serializer.toJson<String>(semesterId),
      'name': serializer.toJson<String>(name),
      'faculty': serializer.toJson<String?>(faculty),
      'type': serializer.toJson<String>(type),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  SubjectEntity copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    int? syncVersion,
    bool? createdOffline,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    String? id,
    String? userId,
    String? semesterId,
    String? name,
    Value<String?> faculty = const Value.absent(),
    String? type,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => SubjectEntity(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    syncVersion: syncVersion ?? this.syncVersion,
    createdOffline: createdOffline ?? this.createdOffline,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    id: id ?? this.id,
    userId: userId ?? this.userId,
    semesterId: semesterId ?? this.semesterId,
    name: name ?? this.name,
    faculty: faculty.present ? faculty.value : this.faculty,
    type: type ?? this.type,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  SubjectEntity copyWithCompanion(SubjectsCompanion data) {
    return SubjectEntity(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
      createdOffline: data.createdOffline.present
          ? data.createdOffline.value
          : this.createdOffline,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      semesterId: data.semesterId.present
          ? data.semesterId.value
          : this.semesterId,
      name: data.name.present ? data.name.value : this.name,
      faculty: data.faculty.present ? data.faculty.value : this.faculty,
      type: data.type.present ? data.type.value : this.type,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubjectEntity(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('createdOffline: $createdOffline, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('semesterId: $semesterId, ')
          ..write('name: $name, ')
          ..write('faculty: $faculty, ')
          ..write('type: $type, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    syncStatus,
    syncVersion,
    createdOffline,
    lastSyncedAt,
    id,
    userId,
    semesterId,
    name,
    faculty,
    type,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubjectEntity &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.syncVersion == this.syncVersion &&
          other.createdOffline == this.createdOffline &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.semesterId == this.semesterId &&
          other.name == this.name &&
          other.faculty == this.faculty &&
          other.type == this.type &&
          other.deletedAt == this.deletedAt);
}

class SubjectsCompanion extends UpdateCompanion<SubjectEntity> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> syncVersion;
  final Value<bool> createdOffline;
  final Value<DateTime?> lastSyncedAt;
  final Value<String> id;
  final Value<String> userId;
  final Value<String> semesterId;
  final Value<String> name;
  final Value<String?> faculty;
  final Value<String> type;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const SubjectsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.createdOffline = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.semesterId = const Value.absent(),
    this.name = const Value.absent(),
    this.faculty = const Value.absent(),
    this.type = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubjectsCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.createdOffline = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    required String id,
    required String userId,
    required String semesterId,
    required String name,
    this.faculty = const Value.absent(),
    this.type = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       semesterId = Value(semesterId),
       name = Value(name);
  static Insertable<SubjectEntity> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? syncVersion,
    Expression<bool>? createdOffline,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? semesterId,
    Expression<String>? name,
    Expression<String>? faculty,
    Expression<String>? type,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (createdOffline != null) 'created_offline': createdOffline,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (semesterId != null) 'semester_id': semesterId,
      if (name != null) 'name': name,
      if (faculty != null) 'faculty': faculty,
      if (type != null) 'type': type,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubjectsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncStatus,
    Value<int>? syncVersion,
    Value<bool>? createdOffline,
    Value<DateTime?>? lastSyncedAt,
    Value<String>? id,
    Value<String>? userId,
    Value<String>? semesterId,
    Value<String>? name,
    Value<String?>? faculty,
    Value<String>? type,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return SubjectsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncVersion: syncVersion ?? this.syncVersion,
      createdOffline: createdOffline ?? this.createdOffline,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      semesterId: semesterId ?? this.semesterId,
      name: name ?? this.name,
      faculty: faculty ?? this.faculty,
      type: type ?? this.type,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (createdOffline.present) {
      map['created_offline'] = Variable<bool>(createdOffline.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (semesterId.present) {
      map['semester_id'] = Variable<String>(semesterId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (faculty.present) {
      map['faculty'] = Variable<String>(faculty.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubjectsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('createdOffline: $createdOffline, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('semesterId: $semesterId, ')
          ..write('name: $name, ')
          ..write('faculty: $faculty, ')
          ..write('type: $type, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimetableTable extends Timetable
    with TableInfo<$TimetableTable, TimetableEntryEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimetableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdOfflineMeta = const VerificationMeta(
    'createdOffline',
  );
  @override
  late final GeneratedColumn<bool> createdOffline = GeneratedColumn<bool>(
    'created_offline',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("created_offline" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayOfWeekMeta = const VerificationMeta(
    'dayOfWeek',
  );
  @override
  late final GeneratedColumn<int> dayOfWeek = GeneratedColumn<int>(
    'day_of_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roomMeta = const VerificationMeta('room');
  @override
  late final GeneratedColumn<String> room = GeneratedColumn<String>(
    'room',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lectureTypeMeta = const VerificationMeta(
    'lectureType',
  );
  @override
  late final GeneratedColumn<String> lectureType = GeneratedColumn<String>(
    'lecture_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('theory'),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    syncStatus,
    syncVersion,
    createdOffline,
    lastSyncedAt,
    id,
    userId,
    subjectId,
    dayOfWeek,
    startTime,
    endTime,
    room,
    lectureType,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timetable';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimetableEntryEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    if (data.containsKey('created_offline')) {
      context.handle(
        _createdOfflineMeta,
        createdOffline.isAcceptableOrUnknown(
          data['created_offline']!,
          _createdOfflineMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('day_of_week')) {
      context.handle(
        _dayOfWeekMeta,
        dayOfWeek.isAcceptableOrUnknown(data['day_of_week']!, _dayOfWeekMeta),
      );
    } else if (isInserting) {
      context.missing(_dayOfWeekMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('room')) {
      context.handle(
        _roomMeta,
        room.isAcceptableOrUnknown(data['room']!, _roomMeta),
      );
    }
    if (data.containsKey('lecture_type')) {
      context.handle(
        _lectureTypeMeta,
        lectureType.isAcceptableOrUnknown(
          data['lecture_type']!,
          _lectureTypeMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimetableEntryEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimetableEntryEntity(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
      createdOffline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}created_offline'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      )!,
      dayOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_week'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_time'],
      )!,
      room: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room'],
      ),
      lectureType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lecture_type'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TimetableTable createAlias(String alias) {
    return $TimetableTable(attachedDatabase, alias);
  }
}

class TimetableEntryEntity extends DataClass
    implements Insertable<TimetableEntryEntity> {
  /// UTC creation timestamp.
  final DateTime createdAt;

  /// UTC last-modified timestamp — sync bookkeeping; bumped on every local
  /// write. Repositories set this explicitly (no local auto-touch trigger,
  /// to keep DateTime text-format consistency with Drift's reader).
  final DateTime updatedAt;

  /// Per-row sync state: `pending`, `synced`, or `failed`.
  final String syncStatus;

  /// Bumped on each local change; aids conflict detection (Phase 5).
  final int syncVersion;

  /// Whether this row was created while offline (offline-first origin).
  final bool createdOffline;

  /// Timestamp of the last successful cloud push. NULL if never synced
  /// (spec §11 "Sync timestamp").
  final DateTime? lastSyncedAt;

  /// UUID primary key.
  final String id;

  /// User ID (Supabase Auth UID). Denormalized for filtering.
  final String userId;

  /// The subject taught in this slot. Semester is resolved via
  /// subjects.semesterId.
  final String subjectId;

  /// ISO 8601 day: 0=Monday, 6=Sunday.
  final int dayOfWeek;

  /// Lecture start time (local). Stored as zero-padded `HH:MM[:SS]`.
  final String startTime;

  /// Lecture end time (local). Must be after start_time (enforced by the
  /// `chk_timetable_time_order` table constraint; lexicographic comparison
  /// is valid for zero-padded times).
  final String endTime;

  /// Classroom or lab identifier. Nullable.
  final String? room;

  /// Type of lecture: theory, practical, or tutorial.
  final String lectureType;

  /// Soft delete: NULL = active, timestamp = deleted.
  final DateTime? deletedAt;
  const TimetableEntryEntity({
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.syncVersion,
    required this.createdOffline,
    this.lastSyncedAt,
    required this.id,
    required this.userId,
    required this.subjectId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
    required this.lectureType,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    map['sync_version'] = Variable<int>(syncVersion);
    map['created_offline'] = Variable<bool>(createdOffline);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['subject_id'] = Variable<String>(subjectId);
    map['day_of_week'] = Variable<int>(dayOfWeek);
    map['start_time'] = Variable<String>(startTime);
    map['end_time'] = Variable<String>(endTime);
    if (!nullToAbsent || room != null) {
      map['room'] = Variable<String>(room);
    }
    map['lecture_type'] = Variable<String>(lectureType);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TimetableCompanion toCompanion(bool nullToAbsent) {
    return TimetableCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      syncVersion: Value(syncVersion),
      createdOffline: Value(createdOffline),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      id: Value(id),
      userId: Value(userId),
      subjectId: Value(subjectId),
      dayOfWeek: Value(dayOfWeek),
      startTime: Value(startTime),
      endTime: Value(endTime),
      room: room == null && nullToAbsent ? const Value.absent() : Value(room),
      lectureType: Value(lectureType),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TimetableEntryEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimetableEntryEntity(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
      createdOffline: serializer.fromJson<bool>(json['createdOffline']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      dayOfWeek: serializer.fromJson<int>(json['dayOfWeek']),
      startTime: serializer.fromJson<String>(json['startTime']),
      endTime: serializer.fromJson<String>(json['endTime']),
      room: serializer.fromJson<String?>(json['room']),
      lectureType: serializer.fromJson<String>(json['lectureType']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncVersion': serializer.toJson<int>(syncVersion),
      'createdOffline': serializer.toJson<bool>(createdOffline),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'subjectId': serializer.toJson<String>(subjectId),
      'dayOfWeek': serializer.toJson<int>(dayOfWeek),
      'startTime': serializer.toJson<String>(startTime),
      'endTime': serializer.toJson<String>(endTime),
      'room': serializer.toJson<String?>(room),
      'lectureType': serializer.toJson<String>(lectureType),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TimetableEntryEntity copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    int? syncVersion,
    bool? createdOffline,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    String? id,
    String? userId,
    String? subjectId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    Value<String?> room = const Value.absent(),
    String? lectureType,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => TimetableEntryEntity(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    syncVersion: syncVersion ?? this.syncVersion,
    createdOffline: createdOffline ?? this.createdOffline,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    id: id ?? this.id,
    userId: userId ?? this.userId,
    subjectId: subjectId ?? this.subjectId,
    dayOfWeek: dayOfWeek ?? this.dayOfWeek,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    room: room.present ? room.value : this.room,
    lectureType: lectureType ?? this.lectureType,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  TimetableEntryEntity copyWithCompanion(TimetableCompanion data) {
    return TimetableEntryEntity(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
      createdOffline: data.createdOffline.present
          ? data.createdOffline.value
          : this.createdOffline,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      room: data.room.present ? data.room.value : this.room,
      lectureType: data.lectureType.present
          ? data.lectureType.value
          : this.lectureType,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimetableEntryEntity(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('createdOffline: $createdOffline, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('subjectId: $subjectId, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('room: $room, ')
          ..write('lectureType: $lectureType, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    syncStatus,
    syncVersion,
    createdOffline,
    lastSyncedAt,
    id,
    userId,
    subjectId,
    dayOfWeek,
    startTime,
    endTime,
    room,
    lectureType,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimetableEntryEntity &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.syncVersion == this.syncVersion &&
          other.createdOffline == this.createdOffline &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.subjectId == this.subjectId &&
          other.dayOfWeek == this.dayOfWeek &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.room == this.room &&
          other.lectureType == this.lectureType &&
          other.deletedAt == this.deletedAt);
}

class TimetableCompanion extends UpdateCompanion<TimetableEntryEntity> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> syncVersion;
  final Value<bool> createdOffline;
  final Value<DateTime?> lastSyncedAt;
  final Value<String> id;
  final Value<String> userId;
  final Value<String> subjectId;
  final Value<int> dayOfWeek;
  final Value<String> startTime;
  final Value<String> endTime;
  final Value<String?> room;
  final Value<String> lectureType;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TimetableCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.createdOffline = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.room = const Value.absent(),
    this.lectureType = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimetableCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.createdOffline = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    required String id,
    required String userId,
    required String subjectId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    this.room = const Value.absent(),
    this.lectureType = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       subjectId = Value(subjectId),
       dayOfWeek = Value(dayOfWeek),
       startTime = Value(startTime),
       endTime = Value(endTime);
  static Insertable<TimetableEntryEntity> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? syncVersion,
    Expression<bool>? createdOffline,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? subjectId,
    Expression<int>? dayOfWeek,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<String>? room,
    Expression<String>? lectureType,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (createdOffline != null) 'created_offline': createdOffline,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (subjectId != null) 'subject_id': subjectId,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (room != null) 'room': room,
      if (lectureType != null) 'lecture_type': lectureType,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimetableCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncStatus,
    Value<int>? syncVersion,
    Value<bool>? createdOffline,
    Value<DateTime?>? lastSyncedAt,
    Value<String>? id,
    Value<String>? userId,
    Value<String>? subjectId,
    Value<int>? dayOfWeek,
    Value<String>? startTime,
    Value<String>? endTime,
    Value<String?>? room,
    Value<String>? lectureType,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return TimetableCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncVersion: syncVersion ?? this.syncVersion,
      createdOffline: createdOffline ?? this.createdOffline,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subjectId: subjectId ?? this.subjectId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      lectureType: lectureType ?? this.lectureType,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (createdOffline.present) {
      map['created_offline'] = Variable<bool>(createdOffline.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<int>(dayOfWeek.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (room.present) {
      map['room'] = Variable<String>(room.value);
    }
    if (lectureType.present) {
      map['lecture_type'] = Variable<String>(lectureType.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimetableCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('createdOffline: $createdOffline, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('subjectId: $subjectId, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('room: $room, ')
          ..write('lectureType: $lectureType, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LectureRecordsTable extends LectureRecords
    with TableInfo<$LectureRecordsTable, LectureRecordEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LectureRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdOfflineMeta = const VerificationMeta(
    'createdOffline',
  );
  @override
  late final GeneratedColumn<bool> createdOffline = GeneratedColumn<bool>(
    'created_offline',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("created_offline" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timetableIdMeta = const VerificationMeta(
    'timetableId',
  );
  @override
  late final GeneratedColumn<String> timetableId = GeneratedColumn<String>(
    'timetable_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _semesterIdMeta = const VerificationMeta(
    'semesterId',
  );
  @override
  late final GeneratedColumn<String> semesterId = GeneratedColumn<String>(
    'semester_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusTextMeta = const VerificationMeta(
    'statusText',
  );
  @override
  late final GeneratedColumn<String> statusText = GeneratedColumn<String>(
    'status_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceTimezoneMeta = const VerificationMeta(
    'deviceTimezone',
  );
  @override
  late final GeneratedColumn<String> deviceTimezone = GeneratedColumn<String>(
    'device_timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appVersionMeta = const VerificationMeta(
    'appVersion',
  );
  @override
  late final GeneratedColumn<String> appVersion = GeneratedColumn<String>(
    'app_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    syncStatus,
    syncVersion,
    createdOffline,
    lastSyncedAt,
    id,
    timetableId,
    subjectId,
    semesterId,
    userId,
    statusText,
    note,
    recordedAt,
    deviceTimezone,
    appVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lecture_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<LectureRecordEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    if (data.containsKey('created_offline')) {
      context.handle(
        _createdOfflineMeta,
        createdOffline.isAcceptableOrUnknown(
          data['created_offline']!,
          _createdOfflineMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('timetable_id')) {
      context.handle(
        _timetableIdMeta,
        timetableId.isAcceptableOrUnknown(
          data['timetable_id']!,
          _timetableIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timetableIdMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('semester_id')) {
      context.handle(
        _semesterIdMeta,
        semesterId.isAcceptableOrUnknown(data['semester_id']!, _semesterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_semesterIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('status_text')) {
      context.handle(
        _statusTextMeta,
        statusText.isAcceptableOrUnknown(data['status_text']!, _statusTextMeta),
      );
    } else if (isInserting) {
      context.missing(_statusTextMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('device_timezone')) {
      context.handle(
        _deviceTimezoneMeta,
        deviceTimezone.isAcceptableOrUnknown(
          data['device_timezone']!,
          _deviceTimezoneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deviceTimezoneMeta);
    }
    if (data.containsKey('app_version')) {
      context.handle(
        _appVersionMeta,
        appVersion.isAcceptableOrUnknown(data['app_version']!, _appVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_appVersionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {timetableId},
  ];
  @override
  LectureRecordEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LectureRecordEntity(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
      createdOffline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}created_offline'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      timetableId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timetable_id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      )!,
      semesterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}semester_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      statusText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_text'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      deviceTimezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_timezone'],
      )!,
      appVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_version'],
      )!,
    );
  }

  @override
  $LectureRecordsTable createAlias(String alias) {
    return $LectureRecordsTable(attachedDatabase, alias);
  }
}

class LectureRecordEntity extends DataClass
    implements Insertable<LectureRecordEntity> {
  /// UTC creation timestamp.
  final DateTime createdAt;

  /// UTC last-modified timestamp — sync bookkeeping; bumped on every local
  /// write. Repositories set this explicitly (no local auto-touch trigger,
  /// to keep DateTime text-format consistency with Drift's reader).
  final DateTime updatedAt;

  /// Per-row sync state: `pending`, `synced`, or `failed`.
  final String syncStatus;

  /// Bumped on each local change; aids conflict detection (Phase 5).
  final int syncVersion;

  /// Whether this row was created while offline (offline-first origin).
  final bool createdOffline;

  /// Timestamp of the last successful cloud push. NULL if never synced
  /// (spec §11 "Sync timestamp").
  final DateTime? lastSyncedAt;

  /// UUID primary key.
  final String id;

  /// 1:1 link to the timetable entry; UNIQUE enforces one record per
  /// lecture slot (spec §3).
  final String timetableId;

  /// Subject for this lecture (from the timetable slot).
  final String subjectId;

  /// Denormalized from `subjects` for per-semester export/verification.
  final String semesterId;

  /// Owner — RLS filter key.
  final String userId;

  /// Encoded primary + secondary status (spec §5). Format:
  /// `"primary|secondary"` (e.g. `"present|"`, `"absent|holiday"`).
  /// The "Other" secondary status carries its custom text after a second
  /// pipe: `"absent|other|Family emergency"`.
  final String statusText;

  /// Optional immutable note (spec §7).
  final String? note;

  /// UTC instant the record was created (user-facing "recorded at").
  final DateTime recordedAt;

  /// Local timezone when the record was created (spec §11; drives the
  /// ≤23:59-local-lecture-day evidence window, spec §9).
  final String deviceTimezone;

  /// App version that created this record (spec §11).
  final String appVersion;
  const LectureRecordEntity({
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.syncVersion,
    required this.createdOffline,
    this.lastSyncedAt,
    required this.id,
    required this.timetableId,
    required this.subjectId,
    required this.semesterId,
    required this.userId,
    required this.statusText,
    this.note,
    required this.recordedAt,
    required this.deviceTimezone,
    required this.appVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    map['sync_version'] = Variable<int>(syncVersion);
    map['created_offline'] = Variable<bool>(createdOffline);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['id'] = Variable<String>(id);
    map['timetable_id'] = Variable<String>(timetableId);
    map['subject_id'] = Variable<String>(subjectId);
    map['semester_id'] = Variable<String>(semesterId);
    map['user_id'] = Variable<String>(userId);
    map['status_text'] = Variable<String>(statusText);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['device_timezone'] = Variable<String>(deviceTimezone);
    map['app_version'] = Variable<String>(appVersion);
    return map;
  }

  LectureRecordsCompanion toCompanion(bool nullToAbsent) {
    return LectureRecordsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      syncVersion: Value(syncVersion),
      createdOffline: Value(createdOffline),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      id: Value(id),
      timetableId: Value(timetableId),
      subjectId: Value(subjectId),
      semesterId: Value(semesterId),
      userId: Value(userId),
      statusText: Value(statusText),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      recordedAt: Value(recordedAt),
      deviceTimezone: Value(deviceTimezone),
      appVersion: Value(appVersion),
    );
  }

  factory LectureRecordEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LectureRecordEntity(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
      createdOffline: serializer.fromJson<bool>(json['createdOffline']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      id: serializer.fromJson<String>(json['id']),
      timetableId: serializer.fromJson<String>(json['timetableId']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      semesterId: serializer.fromJson<String>(json['semesterId']),
      userId: serializer.fromJson<String>(json['userId']),
      statusText: serializer.fromJson<String>(json['statusText']),
      note: serializer.fromJson<String?>(json['note']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      deviceTimezone: serializer.fromJson<String>(json['deviceTimezone']),
      appVersion: serializer.fromJson<String>(json['appVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncVersion': serializer.toJson<int>(syncVersion),
      'createdOffline': serializer.toJson<bool>(createdOffline),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'id': serializer.toJson<String>(id),
      'timetableId': serializer.toJson<String>(timetableId),
      'subjectId': serializer.toJson<String>(subjectId),
      'semesterId': serializer.toJson<String>(semesterId),
      'userId': serializer.toJson<String>(userId),
      'statusText': serializer.toJson<String>(statusText),
      'note': serializer.toJson<String?>(note),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'deviceTimezone': serializer.toJson<String>(deviceTimezone),
      'appVersion': serializer.toJson<String>(appVersion),
    };
  }

  LectureRecordEntity copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    int? syncVersion,
    bool? createdOffline,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    String? id,
    String? timetableId,
    String? subjectId,
    String? semesterId,
    String? userId,
    String? statusText,
    Value<String?> note = const Value.absent(),
    DateTime? recordedAt,
    String? deviceTimezone,
    String? appVersion,
  }) => LectureRecordEntity(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    syncVersion: syncVersion ?? this.syncVersion,
    createdOffline: createdOffline ?? this.createdOffline,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    id: id ?? this.id,
    timetableId: timetableId ?? this.timetableId,
    subjectId: subjectId ?? this.subjectId,
    semesterId: semesterId ?? this.semesterId,
    userId: userId ?? this.userId,
    statusText: statusText ?? this.statusText,
    note: note.present ? note.value : this.note,
    recordedAt: recordedAt ?? this.recordedAt,
    deviceTimezone: deviceTimezone ?? this.deviceTimezone,
    appVersion: appVersion ?? this.appVersion,
  );
  LectureRecordEntity copyWithCompanion(LectureRecordsCompanion data) {
    return LectureRecordEntity(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
      createdOffline: data.createdOffline.present
          ? data.createdOffline.value
          : this.createdOffline,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      id: data.id.present ? data.id.value : this.id,
      timetableId: data.timetableId.present
          ? data.timetableId.value
          : this.timetableId,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      semesterId: data.semesterId.present
          ? data.semesterId.value
          : this.semesterId,
      userId: data.userId.present ? data.userId.value : this.userId,
      statusText: data.statusText.present
          ? data.statusText.value
          : this.statusText,
      note: data.note.present ? data.note.value : this.note,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      deviceTimezone: data.deviceTimezone.present
          ? data.deviceTimezone.value
          : this.deviceTimezone,
      appVersion: data.appVersion.present
          ? data.appVersion.value
          : this.appVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LectureRecordEntity(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('createdOffline: $createdOffline, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('id: $id, ')
          ..write('timetableId: $timetableId, ')
          ..write('subjectId: $subjectId, ')
          ..write('semesterId: $semesterId, ')
          ..write('userId: $userId, ')
          ..write('statusText: $statusText, ')
          ..write('note: $note, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('deviceTimezone: $deviceTimezone, ')
          ..write('appVersion: $appVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    syncStatus,
    syncVersion,
    createdOffline,
    lastSyncedAt,
    id,
    timetableId,
    subjectId,
    semesterId,
    userId,
    statusText,
    note,
    recordedAt,
    deviceTimezone,
    appVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LectureRecordEntity &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.syncVersion == this.syncVersion &&
          other.createdOffline == this.createdOffline &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.id == this.id &&
          other.timetableId == this.timetableId &&
          other.subjectId == this.subjectId &&
          other.semesterId == this.semesterId &&
          other.userId == this.userId &&
          other.statusText == this.statusText &&
          other.note == this.note &&
          other.recordedAt == this.recordedAt &&
          other.deviceTimezone == this.deviceTimezone &&
          other.appVersion == this.appVersion);
}

class LectureRecordsCompanion extends UpdateCompanion<LectureRecordEntity> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> syncVersion;
  final Value<bool> createdOffline;
  final Value<DateTime?> lastSyncedAt;
  final Value<String> id;
  final Value<String> timetableId;
  final Value<String> subjectId;
  final Value<String> semesterId;
  final Value<String> userId;
  final Value<String> statusText;
  final Value<String?> note;
  final Value<DateTime> recordedAt;
  final Value<String> deviceTimezone;
  final Value<String> appVersion;
  final Value<int> rowid;
  const LectureRecordsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.createdOffline = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.timetableId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.semesterId = const Value.absent(),
    this.userId = const Value.absent(),
    this.statusText = const Value.absent(),
    this.note = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.deviceTimezone = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LectureRecordsCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.createdOffline = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    required String id,
    required String timetableId,
    required String subjectId,
    required String semesterId,
    required String userId,
    required String statusText,
    this.note = const Value.absent(),
    required DateTime recordedAt,
    required String deviceTimezone,
    required String appVersion,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       timetableId = Value(timetableId),
       subjectId = Value(subjectId),
       semesterId = Value(semesterId),
       userId = Value(userId),
       statusText = Value(statusText),
       recordedAt = Value(recordedAt),
       deviceTimezone = Value(deviceTimezone),
       appVersion = Value(appVersion);
  static Insertable<LectureRecordEntity> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? syncVersion,
    Expression<bool>? createdOffline,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? id,
    Expression<String>? timetableId,
    Expression<String>? subjectId,
    Expression<String>? semesterId,
    Expression<String>? userId,
    Expression<String>? statusText,
    Expression<String>? note,
    Expression<DateTime>? recordedAt,
    Expression<String>? deviceTimezone,
    Expression<String>? appVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (createdOffline != null) 'created_offline': createdOffline,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (id != null) 'id': id,
      if (timetableId != null) 'timetable_id': timetableId,
      if (subjectId != null) 'subject_id': subjectId,
      if (semesterId != null) 'semester_id': semesterId,
      if (userId != null) 'user_id': userId,
      if (statusText != null) 'status_text': statusText,
      if (note != null) 'note': note,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (deviceTimezone != null) 'device_timezone': deviceTimezone,
      if (appVersion != null) 'app_version': appVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LectureRecordsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncStatus,
    Value<int>? syncVersion,
    Value<bool>? createdOffline,
    Value<DateTime?>? lastSyncedAt,
    Value<String>? id,
    Value<String>? timetableId,
    Value<String>? subjectId,
    Value<String>? semesterId,
    Value<String>? userId,
    Value<String>? statusText,
    Value<String?>? note,
    Value<DateTime>? recordedAt,
    Value<String>? deviceTimezone,
    Value<String>? appVersion,
    Value<int>? rowid,
  }) {
    return LectureRecordsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncVersion: syncVersion ?? this.syncVersion,
      createdOffline: createdOffline ?? this.createdOffline,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      id: id ?? this.id,
      timetableId: timetableId ?? this.timetableId,
      subjectId: subjectId ?? this.subjectId,
      semesterId: semesterId ?? this.semesterId,
      userId: userId ?? this.userId,
      statusText: statusText ?? this.statusText,
      note: note ?? this.note,
      recordedAt: recordedAt ?? this.recordedAt,
      deviceTimezone: deviceTimezone ?? this.deviceTimezone,
      appVersion: appVersion ?? this.appVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (createdOffline.present) {
      map['created_offline'] = Variable<bool>(createdOffline.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (timetableId.present) {
      map['timetable_id'] = Variable<String>(timetableId.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (semesterId.present) {
      map['semester_id'] = Variable<String>(semesterId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (statusText.present) {
      map['status_text'] = Variable<String>(statusText.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (deviceTimezone.present) {
      map['device_timezone'] = Variable<String>(deviceTimezone.value);
    }
    if (appVersion.present) {
      map['app_version'] = Variable<String>(appVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LectureRecordsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('createdOffline: $createdOffline, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('id: $id, ')
          ..write('timetableId: $timetableId, ')
          ..write('subjectId: $subjectId, ')
          ..write('semesterId: $semesterId, ')
          ..write('userId: $userId, ')
          ..write('statusText: $statusText, ')
          ..write('note: $note, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('deviceTimezone: $deviceTimezone, ')
          ..write('appVersion: $appVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssignmentsTable extends Assignments
    with TableInfo<$AssignmentsTable, AssignmentEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssignmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdOfflineMeta = const VerificationMeta(
    'createdOffline',
  );
  @override
  late final GeneratedColumn<bool> createdOffline = GeneratedColumn<bool>(
    'created_offline',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("created_offline" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    syncStatus,
    syncVersion,
    createdOffline,
    lastSyncedAt,
    id,
    userId,
    subjectId,
    title,
    description,
    dueDate,
    status,
    completedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assignments';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssignmentEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    if (data.containsKey('created_offline')) {
      context.handle(
        _createdOfflineMeta,
        createdOffline.isAcceptableOrUnknown(
          data['created_offline']!,
          _createdOfflineMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssignmentEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssignmentEntity(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
      createdOffline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}created_offline'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $AssignmentsTable createAlias(String alias) {
    return $AssignmentsTable(attachedDatabase, alias);
  }
}

class AssignmentEntity extends DataClass
    implements Insertable<AssignmentEntity> {
  /// UTC creation timestamp.
  final DateTime createdAt;

  /// UTC last-modified timestamp — sync bookkeeping; bumped on every local
  /// write. Repositories set this explicitly (no local auto-touch trigger,
  /// to keep DateTime text-format consistency with Drift's reader).
  final DateTime updatedAt;

  /// Per-row sync state: `pending`, `synced`, or `failed`.
  final String syncStatus;

  /// Bumped on each local change; aids conflict detection (Phase 5).
  final int syncVersion;

  /// Whether this row was created while offline (offline-first origin).
  final bool createdOffline;

  /// Timestamp of the last successful cloud push. NULL if never synced
  /// (spec §11 "Sync timestamp").
  final DateTime? lastSyncedAt;

  /// UUID primary key.
  final String id;

  /// User ID (Supabase Auth UID). Denormalized for filtering.
  final String userId;

  /// The subject this assignment belongs to.
  final String subjectId;

  /// Assignment title.
  final String title;

  /// Optional detailed description of the assignment.
  final String? description;

  /// The date the assignment is due, as ISO 8601 `YYYY-MM-DD`.
  /// Kept as text (date-only) so lexicographic order matches date order.
  final String dueDate;

  /// Assignment status: pending or completed.
  final String status;

  /// Timestamp when status changed to completed. NULL while pending.
  final DateTime? completedAt;

  /// Soft delete: NULL = active, timestamp = deleted.
  final DateTime? deletedAt;
  const AssignmentEntity({
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.syncVersion,
    required this.createdOffline,
    this.lastSyncedAt,
    required this.id,
    required this.userId,
    required this.subjectId,
    required this.title,
    this.description,
    required this.dueDate,
    required this.status,
    this.completedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    map['sync_version'] = Variable<int>(syncVersion);
    map['created_offline'] = Variable<bool>(createdOffline);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['subject_id'] = Variable<String>(subjectId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['due_date'] = Variable<String>(dueDate);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  AssignmentsCompanion toCompanion(bool nullToAbsent) {
    return AssignmentsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      syncVersion: Value(syncVersion),
      createdOffline: Value(createdOffline),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      id: Value(id),
      userId: Value(userId),
      subjectId: Value(subjectId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      dueDate: Value(dueDate),
      status: Value(status),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory AssignmentEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssignmentEntity(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
      createdOffline: serializer.fromJson<bool>(json['createdOffline']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      dueDate: serializer.fromJson<String>(json['dueDate']),
      status: serializer.fromJson<String>(json['status']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncVersion': serializer.toJson<int>(syncVersion),
      'createdOffline': serializer.toJson<bool>(createdOffline),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'subjectId': serializer.toJson<String>(subjectId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'dueDate': serializer.toJson<String>(dueDate),
      'status': serializer.toJson<String>(status),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  AssignmentEntity copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    int? syncVersion,
    bool? createdOffline,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    String? id,
    String? userId,
    String? subjectId,
    String? title,
    Value<String?> description = const Value.absent(),
    String? dueDate,
    String? status,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => AssignmentEntity(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    syncVersion: syncVersion ?? this.syncVersion,
    createdOffline: createdOffline ?? this.createdOffline,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    id: id ?? this.id,
    userId: userId ?? this.userId,
    subjectId: subjectId ?? this.subjectId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    dueDate: dueDate ?? this.dueDate,
    status: status ?? this.status,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  AssignmentEntity copyWithCompanion(AssignmentsCompanion data) {
    return AssignmentEntity(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
      createdOffline: data.createdOffline.present
          ? data.createdOffline.value
          : this.createdOffline,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      status: data.status.present ? data.status.value : this.status,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssignmentEntity(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('createdOffline: $createdOffline, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('subjectId: $subjectId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    syncStatus,
    syncVersion,
    createdOffline,
    lastSyncedAt,
    id,
    userId,
    subjectId,
    title,
    description,
    dueDate,
    status,
    completedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssignmentEntity &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.syncVersion == this.syncVersion &&
          other.createdOffline == this.createdOffline &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.subjectId == this.subjectId &&
          other.title == this.title &&
          other.description == this.description &&
          other.dueDate == this.dueDate &&
          other.status == this.status &&
          other.completedAt == this.completedAt &&
          other.deletedAt == this.deletedAt);
}

class AssignmentsCompanion extends UpdateCompanion<AssignmentEntity> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> syncVersion;
  final Value<bool> createdOffline;
  final Value<DateTime?> lastSyncedAt;
  final Value<String> id;
  final Value<String> userId;
  final Value<String> subjectId;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> dueDate;
  final Value<String> status;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const AssignmentsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.createdOffline = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssignmentsCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.createdOffline = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    required String id,
    required String userId,
    required String subjectId,
    required String title,
    this.description = const Value.absent(),
    required String dueDate,
    this.status = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       subjectId = Value(subjectId),
       title = Value(title),
       dueDate = Value(dueDate);
  static Insertable<AssignmentEntity> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? syncVersion,
    Expression<bool>? createdOffline,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? subjectId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? dueDate,
    Expression<String>? status,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (createdOffline != null) 'created_offline': createdOffline,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (subjectId != null) 'subject_id': subjectId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (dueDate != null) 'due_date': dueDate,
      if (status != null) 'status': status,
      if (completedAt != null) 'completed_at': completedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssignmentsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncStatus,
    Value<int>? syncVersion,
    Value<bool>? createdOffline,
    Value<DateTime?>? lastSyncedAt,
    Value<String>? id,
    Value<String>? userId,
    Value<String>? subjectId,
    Value<String>? title,
    Value<String?>? description,
    Value<String>? dueDate,
    Value<String>? status,
    Value<DateTime?>? completedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return AssignmentsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncVersion: syncVersion ?? this.syncVersion,
      createdOffline: createdOffline ?? this.createdOffline,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (createdOffline.present) {
      map['created_offline'] = Variable<bool>(createdOffline.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssignmentsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('createdOffline: $createdOffline, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('subjectId: $subjectId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InternalMarksTable extends InternalMarks
    with TableInfo<$InternalMarksTable, InternalMarkEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InternalMarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdOfflineMeta = const VerificationMeta(
    'createdOffline',
  );
  @override
  late final GeneratedColumn<bool> createdOffline = GeneratedColumn<bool>(
    'created_offline',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("created_offline" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _examNameMeta = const VerificationMeta(
    'examName',
  );
  @override
  late final GeneratedColumn<String> examName = GeneratedColumn<String>(
    'exam_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marksObtainedMeta = const VerificationMeta(
    'marksObtained',
  );
  @override
  late final GeneratedColumn<double> marksObtained = GeneratedColumn<double>(
    'marks_obtained',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxMarksMeta = const VerificationMeta(
    'maxMarks',
  );
  @override
  late final GeneratedColumn<double> maxMarks = GeneratedColumn<double>(
    'max_marks',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    syncStatus,
    syncVersion,
    createdOffline,
    lastSyncedAt,
    id,
    userId,
    subjectId,
    examName,
    marksObtained,
    maxMarks,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'internal_marks';
  @override
  VerificationContext validateIntegrity(
    Insertable<InternalMarkEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    if (data.containsKey('created_offline')) {
      context.handle(
        _createdOfflineMeta,
        createdOffline.isAcceptableOrUnknown(
          data['created_offline']!,
          _createdOfflineMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('exam_name')) {
      context.handle(
        _examNameMeta,
        examName.isAcceptableOrUnknown(data['exam_name']!, _examNameMeta),
      );
    } else if (isInserting) {
      context.missing(_examNameMeta);
    }
    if (data.containsKey('marks_obtained')) {
      context.handle(
        _marksObtainedMeta,
        marksObtained.isAcceptableOrUnknown(
          data['marks_obtained']!,
          _marksObtainedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_marksObtainedMeta);
    }
    if (data.containsKey('max_marks')) {
      context.handle(
        _maxMarksMeta,
        maxMarks.isAcceptableOrUnknown(data['max_marks']!, _maxMarksMeta),
      );
    } else if (isInserting) {
      context.missing(_maxMarksMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InternalMarkEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InternalMarkEntity(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
      createdOffline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}created_offline'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      )!,
      examName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exam_name'],
      )!,
      marksObtained: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}marks_obtained'],
      )!,
      maxMarks: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_marks'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $InternalMarksTable createAlias(String alias) {
    return $InternalMarksTable(attachedDatabase, alias);
  }
}

class InternalMarkEntity extends DataClass
    implements Insertable<InternalMarkEntity> {
  /// UTC creation timestamp.
  final DateTime createdAt;

  /// UTC last-modified timestamp — sync bookkeeping; bumped on every local
  /// write. Repositories set this explicitly (no local auto-touch trigger,
  /// to keep DateTime text-format consistency with Drift's reader).
  final DateTime updatedAt;

  /// Per-row sync state: `pending`, `synced`, or `failed`.
  final String syncStatus;

  /// Bumped on each local change; aids conflict detection (Phase 5).
  final int syncVersion;

  /// Whether this row was created while offline (offline-first origin).
  final bool createdOffline;

  /// Timestamp of the last successful cloud push. NULL if never synced
  /// (spec §11 "Sync timestamp").
  final DateTime? lastSyncedAt;

  /// UUID primary key.
  final String id;

  /// User ID (Supabase Auth UID). Denormalized for filtering.
  final String userId;

  /// The subject this assessment belongs to.
  final String subjectId;

  /// Free-form assessment label (e.g., "UT-1", "Mid Sem", "Quiz 3", "Lab Viva").
  final String examName;

  /// Score achieved. Must be >= 0 and <= max_marks.
  final double marksObtained;

  /// Maximum possible score. Must be > 0.
  final double maxMarks;

  /// Soft delete: NULL = active, timestamp = deleted.
  final DateTime? deletedAt;
  const InternalMarkEntity({
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.syncVersion,
    required this.createdOffline,
    this.lastSyncedAt,
    required this.id,
    required this.userId,
    required this.subjectId,
    required this.examName,
    required this.marksObtained,
    required this.maxMarks,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    map['sync_version'] = Variable<int>(syncVersion);
    map['created_offline'] = Variable<bool>(createdOffline);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['subject_id'] = Variable<String>(subjectId);
    map['exam_name'] = Variable<String>(examName);
    map['marks_obtained'] = Variable<double>(marksObtained);
    map['max_marks'] = Variable<double>(maxMarks);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  InternalMarksCompanion toCompanion(bool nullToAbsent) {
    return InternalMarksCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      syncVersion: Value(syncVersion),
      createdOffline: Value(createdOffline),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      id: Value(id),
      userId: Value(userId),
      subjectId: Value(subjectId),
      examName: Value(examName),
      marksObtained: Value(marksObtained),
      maxMarks: Value(maxMarks),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory InternalMarkEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InternalMarkEntity(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
      createdOffline: serializer.fromJson<bool>(json['createdOffline']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      examName: serializer.fromJson<String>(json['examName']),
      marksObtained: serializer.fromJson<double>(json['marksObtained']),
      maxMarks: serializer.fromJson<double>(json['maxMarks']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncVersion': serializer.toJson<int>(syncVersion),
      'createdOffline': serializer.toJson<bool>(createdOffline),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'subjectId': serializer.toJson<String>(subjectId),
      'examName': serializer.toJson<String>(examName),
      'marksObtained': serializer.toJson<double>(marksObtained),
      'maxMarks': serializer.toJson<double>(maxMarks),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  InternalMarkEntity copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    int? syncVersion,
    bool? createdOffline,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    String? id,
    String? userId,
    String? subjectId,
    String? examName,
    double? marksObtained,
    double? maxMarks,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => InternalMarkEntity(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    syncVersion: syncVersion ?? this.syncVersion,
    createdOffline: createdOffline ?? this.createdOffline,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    id: id ?? this.id,
    userId: userId ?? this.userId,
    subjectId: subjectId ?? this.subjectId,
    examName: examName ?? this.examName,
    marksObtained: marksObtained ?? this.marksObtained,
    maxMarks: maxMarks ?? this.maxMarks,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  InternalMarkEntity copyWithCompanion(InternalMarksCompanion data) {
    return InternalMarkEntity(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
      createdOffline: data.createdOffline.present
          ? data.createdOffline.value
          : this.createdOffline,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      examName: data.examName.present ? data.examName.value : this.examName,
      marksObtained: data.marksObtained.present
          ? data.marksObtained.value
          : this.marksObtained,
      maxMarks: data.maxMarks.present ? data.maxMarks.value : this.maxMarks,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InternalMarkEntity(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('createdOffline: $createdOffline, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('subjectId: $subjectId, ')
          ..write('examName: $examName, ')
          ..write('marksObtained: $marksObtained, ')
          ..write('maxMarks: $maxMarks, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    syncStatus,
    syncVersion,
    createdOffline,
    lastSyncedAt,
    id,
    userId,
    subjectId,
    examName,
    marksObtained,
    maxMarks,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InternalMarkEntity &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.syncVersion == this.syncVersion &&
          other.createdOffline == this.createdOffline &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.subjectId == this.subjectId &&
          other.examName == this.examName &&
          other.marksObtained == this.marksObtained &&
          other.maxMarks == this.maxMarks &&
          other.deletedAt == this.deletedAt);
}

class InternalMarksCompanion extends UpdateCompanion<InternalMarkEntity> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> syncVersion;
  final Value<bool> createdOffline;
  final Value<DateTime?> lastSyncedAt;
  final Value<String> id;
  final Value<String> userId;
  final Value<String> subjectId;
  final Value<String> examName;
  final Value<double> marksObtained;
  final Value<double> maxMarks;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const InternalMarksCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.createdOffline = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.examName = const Value.absent(),
    this.marksObtained = const Value.absent(),
    this.maxMarks = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InternalMarksCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.createdOffline = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    required String id,
    required String userId,
    required String subjectId,
    required String examName,
    required double marksObtained,
    required double maxMarks,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       subjectId = Value(subjectId),
       examName = Value(examName),
       marksObtained = Value(marksObtained),
       maxMarks = Value(maxMarks);
  static Insertable<InternalMarkEntity> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? syncVersion,
    Expression<bool>? createdOffline,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? subjectId,
    Expression<String>? examName,
    Expression<double>? marksObtained,
    Expression<double>? maxMarks,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (createdOffline != null) 'created_offline': createdOffline,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (subjectId != null) 'subject_id': subjectId,
      if (examName != null) 'exam_name': examName,
      if (marksObtained != null) 'marks_obtained': marksObtained,
      if (maxMarks != null) 'max_marks': maxMarks,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InternalMarksCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncStatus,
    Value<int>? syncVersion,
    Value<bool>? createdOffline,
    Value<DateTime?>? lastSyncedAt,
    Value<String>? id,
    Value<String>? userId,
    Value<String>? subjectId,
    Value<String>? examName,
    Value<double>? marksObtained,
    Value<double>? maxMarks,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return InternalMarksCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncVersion: syncVersion ?? this.syncVersion,
      createdOffline: createdOffline ?? this.createdOffline,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subjectId: subjectId ?? this.subjectId,
      examName: examName ?? this.examName,
      marksObtained: marksObtained ?? this.marksObtained,
      maxMarks: maxMarks ?? this.maxMarks,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (createdOffline.present) {
      map['created_offline'] = Variable<bool>(createdOffline.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (examName.present) {
      map['exam_name'] = Variable<String>(examName.value);
    }
    if (marksObtained.present) {
      map['marks_obtained'] = Variable<double>(marksObtained.value);
    }
    if (maxMarks.present) {
      map['max_marks'] = Variable<double>(maxMarks.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InternalMarksCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('createdOffline: $createdOffline, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('subjectId: $subjectId, ')
          ..write('examName: $examName, ')
          ..write('marksObtained: $marksObtained, ')
          ..write('maxMarks: $maxMarks, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, UserSettingsEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdOfflineMeta = const VerificationMeta(
    'createdOffline',
  );
  @override
  late final GeneratedColumn<bool> createdOffline = GeneratedColumn<bool>(
    'created_offline',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("created_offline" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<bool> notificationsEnabled = GeneratedColumn<bool>(
    'notifications_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notifications_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _enabledModulesMeta = const VerificationMeta(
    'enabledModules',
  );
  @override
  late final GeneratedColumn<String> enabledModules = GeneratedColumn<String>(
    'enabled_modules',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _themeMeta = const VerificationMeta('theme');
  @override
  late final GeneratedColumn<String> theme = GeneratedColumn<String>(
    'theme',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('dark'),
  );
  static const VerificationMeta _preferencesMeta = const VerificationMeta(
    'preferences',
  );
  @override
  late final GeneratedColumn<String> preferences = GeneratedColumn<String>(
    'preferences',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    syncStatus,
    syncVersion,
    createdOffline,
    lastSyncedAt,
    id,
    userId,
    notificationsEnabled,
    enabledModules,
    theme,
    preferences,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserSettingsEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    if (data.containsKey('created_offline')) {
      context.handle(
        _createdOfflineMeta,
        createdOffline.isAcceptableOrUnknown(
          data['created_offline']!,
          _createdOfflineMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
        _notificationsEnabledMeta,
        notificationsEnabled.isAcceptableOrUnknown(
          data['notifications_enabled']!,
          _notificationsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('enabled_modules')) {
      context.handle(
        _enabledModulesMeta,
        enabledModules.isAcceptableOrUnknown(
          data['enabled_modules']!,
          _enabledModulesMeta,
        ),
      );
    }
    if (data.containsKey('theme')) {
      context.handle(
        _themeMeta,
        theme.isAcceptableOrUnknown(data['theme']!, _themeMeta),
      );
    }
    if (data.containsKey('preferences')) {
      context.handle(
        _preferencesMeta,
        preferences.isAcceptableOrUnknown(
          data['preferences']!,
          _preferencesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {userId},
  ];
  @override
  UserSettingsEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSettingsEntity(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
      createdOffline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}created_offline'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      notificationsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notifications_enabled'],
      )!,
      enabledModules: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enabled_modules'],
      )!,
      theme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme'],
      )!,
      preferences: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferences'],
      )!,
    );
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }
}

class UserSettingsEntity extends DataClass
    implements Insertable<UserSettingsEntity> {
  /// UTC creation timestamp.
  final DateTime createdAt;

  /// UTC last-modified timestamp — sync bookkeeping; bumped on every local
  /// write. Repositories set this explicitly (no local auto-touch trigger,
  /// to keep DateTime text-format consistency with Drift's reader).
  final DateTime updatedAt;

  /// Per-row sync state: `pending`, `synced`, or `failed`.
  final String syncStatus;

  /// Bumped on each local change; aids conflict detection (Phase 5).
  final int syncVersion;

  /// Whether this row was created while offline (offline-first origin).
  final bool createdOffline;

  /// Timestamp of the last successful cloud push. NULL if never synced
  /// (spec §11 "Sync timestamp").
  final DateTime? lastSyncedAt;

  /// UUID primary key.
  final String id;

  /// Owner — 1:1 relationship with users. UNIQUE ensures one settings row
  /// per user (repair of the Phase 4 §A6 "missing user_settings UNIQUE" defect).
  final String userId;

  /// Whether push notifications are enabled.
  final bool notificationsEnabled;

  /// Map of module names to enabled booleans.
  /// Stored as JSON text (e.g., `{"attendance": true, "assignments": true}`).
  final String enabledModules;

  /// UI theme preference. Defaults to 'dark'.
  final String theme;

  /// Flexible JSON catch-all for future user preferences.
  final String preferences;
  const UserSettingsEntity({
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.syncVersion,
    required this.createdOffline,
    this.lastSyncedAt,
    required this.id,
    required this.userId,
    required this.notificationsEnabled,
    required this.enabledModules,
    required this.theme,
    required this.preferences,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    map['sync_version'] = Variable<int>(syncVersion);
    map['created_offline'] = Variable<bool>(createdOffline);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    map['enabled_modules'] = Variable<String>(enabledModules);
    map['theme'] = Variable<String>(theme);
    map['preferences'] = Variable<String>(preferences);
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      syncVersion: Value(syncVersion),
      createdOffline: Value(createdOffline),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      id: Value(id),
      userId: Value(userId),
      notificationsEnabled: Value(notificationsEnabled),
      enabledModules: Value(enabledModules),
      theme: Value(theme),
      preferences: Value(preferences),
    );
  }

  factory UserSettingsEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSettingsEntity(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
      createdOffline: serializer.fromJson<bool>(json['createdOffline']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      notificationsEnabled: serializer.fromJson<bool>(
        json['notificationsEnabled'],
      ),
      enabledModules: serializer.fromJson<String>(json['enabledModules']),
      theme: serializer.fromJson<String>(json['theme']),
      preferences: serializer.fromJson<String>(json['preferences']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncVersion': serializer.toJson<int>(syncVersion),
      'createdOffline': serializer.toJson<bool>(createdOffline),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
      'enabledModules': serializer.toJson<String>(enabledModules),
      'theme': serializer.toJson<String>(theme),
      'preferences': serializer.toJson<String>(preferences),
    };
  }

  UserSettingsEntity copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    int? syncVersion,
    bool? createdOffline,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    String? id,
    String? userId,
    bool? notificationsEnabled,
    String? enabledModules,
    String? theme,
    String? preferences,
  }) => UserSettingsEntity(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    syncVersion: syncVersion ?? this.syncVersion,
    createdOffline: createdOffline ?? this.createdOffline,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    id: id ?? this.id,
    userId: userId ?? this.userId,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    enabledModules: enabledModules ?? this.enabledModules,
    theme: theme ?? this.theme,
    preferences: preferences ?? this.preferences,
  );
  UserSettingsEntity copyWithCompanion(UserSettingsCompanion data) {
    return UserSettingsEntity(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
      createdOffline: data.createdOffline.present
          ? data.createdOffline.value
          : this.createdOffline,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
      enabledModules: data.enabledModules.present
          ? data.enabledModules.value
          : this.enabledModules,
      theme: data.theme.present ? data.theme.value : this.theme,
      preferences: data.preferences.present
          ? data.preferences.value
          : this.preferences,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsEntity(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('createdOffline: $createdOffline, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('enabledModules: $enabledModules, ')
          ..write('theme: $theme, ')
          ..write('preferences: $preferences')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    syncStatus,
    syncVersion,
    createdOffline,
    lastSyncedAt,
    id,
    userId,
    notificationsEnabled,
    enabledModules,
    theme,
    preferences,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSettingsEntity &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.syncVersion == this.syncVersion &&
          other.createdOffline == this.createdOffline &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.enabledModules == this.enabledModules &&
          other.theme == this.theme &&
          other.preferences == this.preferences);
}

class UserSettingsCompanion extends UpdateCompanion<UserSettingsEntity> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> syncVersion;
  final Value<bool> createdOffline;
  final Value<DateTime?> lastSyncedAt;
  final Value<String> id;
  final Value<String> userId;
  final Value<bool> notificationsEnabled;
  final Value<String> enabledModules;
  final Value<String> theme;
  final Value<String> preferences;
  final Value<int> rowid;
  const UserSettingsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.createdOffline = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.enabledModules = const Value.absent(),
    this.theme = const Value.absent(),
    this.preferences = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.createdOffline = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    required String id,
    required String userId,
    this.notificationsEnabled = const Value.absent(),
    this.enabledModules = const Value.absent(),
    this.theme = const Value.absent(),
    this.preferences = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId);
  static Insertable<UserSettingsEntity> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? syncVersion,
    Expression<bool>? createdOffline,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? id,
    Expression<String>? userId,
    Expression<bool>? notificationsEnabled,
    Expression<String>? enabledModules,
    Expression<String>? theme,
    Expression<String>? preferences,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (createdOffline != null) 'created_offline': createdOffline,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (enabledModules != null) 'enabled_modules': enabledModules,
      if (theme != null) 'theme': theme,
      if (preferences != null) 'preferences': preferences,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSettingsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncStatus,
    Value<int>? syncVersion,
    Value<bool>? createdOffline,
    Value<DateTime?>? lastSyncedAt,
    Value<String>? id,
    Value<String>? userId,
    Value<bool>? notificationsEnabled,
    Value<String>? enabledModules,
    Value<String>? theme,
    Value<String>? preferences,
    Value<int>? rowid,
  }) {
    return UserSettingsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncVersion: syncVersion ?? this.syncVersion,
      createdOffline: createdOffline ?? this.createdOffline,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      enabledModules: enabledModules ?? this.enabledModules,
      theme: theme ?? this.theme,
      preferences: preferences ?? this.preferences,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (createdOffline.present) {
      map['created_offline'] = Variable<bool>(createdOffline.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<bool>(notificationsEnabled.value);
    }
    if (enabledModules.present) {
      map['enabled_modules'] = Variable<String>(enabledModules.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(theme.value);
    }
    if (preferences.present) {
      map['preferences'] = Variable<String>(preferences.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('createdOffline: $createdOffline, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('enabledModules: $enabledModules, ')
          ..write('theme: $theme, ')
          ..write('preferences: $preferences, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CalendarEventsTable extends CalendarEvents
    with TableInfo<$CalendarEventsTable, CalendarEventEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _syncVersionMeta = const VerificationMeta(
    'syncVersion',
  );
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
    'sync_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdOfflineMeta = const VerificationMeta(
    'createdOffline',
  );
  @override
  late final GeneratedColumn<bool> createdOffline = GeneratedColumn<bool>(
    'created_offline',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("created_offline" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<String> time = GeneratedColumn<String>(
    'time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    syncStatus,
    syncVersion,
    createdOffline,
    lastSyncedAt,
    id,
    userId,
    title,
    type,
    date,
    time,
    subjectId,
    location,
    notes,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<CalendarEventEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('sync_version')) {
      context.handle(
        _syncVersionMeta,
        syncVersion.isAcceptableOrUnknown(
          data['sync_version']!,
          _syncVersionMeta,
        ),
      );
    }
    if (data.containsKey('created_offline')) {
      context.handle(
        _createdOfflineMeta,
        createdOffline.isAcceptableOrUnknown(
          data['created_offline']!,
          _createdOfflineMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CalendarEventEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarEventEntity(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      syncVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_version'],
      )!,
      createdOffline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}created_offline'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time'],
      ),
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $CalendarEventsTable createAlias(String alias) {
    return $CalendarEventsTable(attachedDatabase, alias);
  }
}

class CalendarEventEntity extends DataClass
    implements Insertable<CalendarEventEntity> {
  /// UTC creation timestamp.
  final DateTime createdAt;

  /// UTC last-modified timestamp — sync bookkeeping; bumped on every local
  /// write. Repositories set this explicitly (no local auto-touch trigger,
  /// to keep DateTime text-format consistency with Drift's reader).
  final DateTime updatedAt;

  /// Per-row sync state: `pending`, `synced`, or `failed`.
  final String syncStatus;

  /// Bumped on each local change; aids conflict detection (Phase 5).
  final int syncVersion;

  /// Whether this row was created while offline (offline-first origin).
  final bool createdOffline;

  /// Timestamp of the last successful cloud push. NULL if never synced
  /// (spec §11 "Sync timestamp").
  final DateTime? lastSyncedAt;

  /// UUID primary key.
  final String id;

  /// Owner — RLS filter key.
  final String userId;

  /// Event title.
  final String title;

  /// Event type: `academic`, `assignment`, `exam`, or `personal`.
  /// Mirrors the `EventType` enum in `calendar/models/mock_event.dart`.
  final String type;

  /// The calendar date of the event.
  final DateTime date;

  /// Local time as `HH:MM`, or NULL for all-day events.
  final String? time;

  /// Optional link to a subject. NULL for personal events.
  final String? subjectId;

  /// Optional location (e.g. "Exam Hall 2", "Lab 3").
  final String? location;

  /// Optional notes.
  final String? notes;

  /// Soft delete: NULL = active, timestamp = deleted.
  final DateTime? deletedAt;
  const CalendarEventEntity({
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.syncVersion,
    required this.createdOffline,
    this.lastSyncedAt,
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    required this.date,
    this.time,
    this.subjectId,
    this.location,
    this.notes,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    map['sync_version'] = Variable<int>(syncVersion);
    map['created_offline'] = Variable<bool>(createdOffline);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    map['type'] = Variable<String>(type);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || time != null) {
      map['time'] = Variable<String>(time);
    }
    if (!nullToAbsent || subjectId != null) {
      map['subject_id'] = Variable<String>(subjectId);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  CalendarEventsCompanion toCompanion(bool nullToAbsent) {
    return CalendarEventsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      syncVersion: Value(syncVersion),
      createdOffline: Value(createdOffline),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      type: Value(type),
      date: Value(date),
      time: time == null && nullToAbsent ? const Value.absent() : Value(time),
      subjectId: subjectId == null && nullToAbsent
          ? const Value.absent()
          : Value(subjectId),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory CalendarEventEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarEventEntity(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
      createdOffline: serializer.fromJson<bool>(json['createdOffline']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      type: serializer.fromJson<String>(json['type']),
      date: serializer.fromJson<DateTime>(json['date']),
      time: serializer.fromJson<String?>(json['time']),
      subjectId: serializer.fromJson<String?>(json['subjectId']),
      location: serializer.fromJson<String?>(json['location']),
      notes: serializer.fromJson<String?>(json['notes']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncVersion': serializer.toJson<int>(syncVersion),
      'createdOffline': serializer.toJson<bool>(createdOffline),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'type': serializer.toJson<String>(type),
      'date': serializer.toJson<DateTime>(date),
      'time': serializer.toJson<String?>(time),
      'subjectId': serializer.toJson<String?>(subjectId),
      'location': serializer.toJson<String?>(location),
      'notes': serializer.toJson<String?>(notes),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  CalendarEventEntity copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    int? syncVersion,
    bool? createdOffline,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    String? id,
    String? userId,
    String? title,
    String? type,
    DateTime? date,
    Value<String?> time = const Value.absent(),
    Value<String?> subjectId = const Value.absent(),
    Value<String?> location = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => CalendarEventEntity(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    syncVersion: syncVersion ?? this.syncVersion,
    createdOffline: createdOffline ?? this.createdOffline,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    type: type ?? this.type,
    date: date ?? this.date,
    time: time.present ? time.value : this.time,
    subjectId: subjectId.present ? subjectId.value : this.subjectId,
    location: location.present ? location.value : this.location,
    notes: notes.present ? notes.value : this.notes,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  CalendarEventEntity copyWithCompanion(CalendarEventsCompanion data) {
    return CalendarEventEntity(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncVersion: data.syncVersion.present
          ? data.syncVersion.value
          : this.syncVersion,
      createdOffline: data.createdOffline.present
          ? data.createdOffline.value
          : this.createdOffline,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      type: data.type.present ? data.type.value : this.type,
      date: data.date.present ? data.date.value : this.date,
      time: data.time.present ? data.time.value : this.time,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      location: data.location.present ? data.location.value : this.location,
      notes: data.notes.present ? data.notes.value : this.notes,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEventEntity(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('createdOffline: $createdOffline, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('date: $date, ')
          ..write('time: $time, ')
          ..write('subjectId: $subjectId, ')
          ..write('location: $location, ')
          ..write('notes: $notes, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    syncStatus,
    syncVersion,
    createdOffline,
    lastSyncedAt,
    id,
    userId,
    title,
    type,
    date,
    time,
    subjectId,
    location,
    notes,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarEventEntity &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.syncVersion == this.syncVersion &&
          other.createdOffline == this.createdOffline &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.type == this.type &&
          other.date == this.date &&
          other.time == this.time &&
          other.subjectId == this.subjectId &&
          other.location == this.location &&
          other.notes == this.notes &&
          other.deletedAt == this.deletedAt);
}

class CalendarEventsCompanion extends UpdateCompanion<CalendarEventEntity> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> syncVersion;
  final Value<bool> createdOffline;
  final Value<DateTime?> lastSyncedAt;
  final Value<String> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<String> type;
  final Value<DateTime> date;
  final Value<String?> time;
  final Value<String?> subjectId;
  final Value<String?> location;
  final Value<String?> notes;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const CalendarEventsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.createdOffline = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.type = const Value.absent(),
    this.date = const Value.absent(),
    this.time = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.location = const Value.absent(),
    this.notes = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalendarEventsCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.createdOffline = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    required String id,
    required String userId,
    required String title,
    required String type,
    required DateTime date,
    this.time = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.location = const Value.absent(),
    this.notes = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       title = Value(title),
       type = Value(type),
       date = Value(date);
  static Insertable<CalendarEventEntity> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? syncVersion,
    Expression<bool>? createdOffline,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? type,
    Expression<DateTime>? date,
    Expression<String>? time,
    Expression<String>? subjectId,
    Expression<String>? location,
    Expression<String>? notes,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (createdOffline != null) 'created_offline': createdOffline,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (type != null) 'type': type,
      if (date != null) 'date': date,
      if (time != null) 'time': time,
      if (subjectId != null) 'subject_id': subjectId,
      if (location != null) 'location': location,
      if (notes != null) 'notes': notes,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalendarEventsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncStatus,
    Value<int>? syncVersion,
    Value<bool>? createdOffline,
    Value<DateTime?>? lastSyncedAt,
    Value<String>? id,
    Value<String>? userId,
    Value<String>? title,
    Value<String>? type,
    Value<DateTime>? date,
    Value<String?>? time,
    Value<String?>? subjectId,
    Value<String?>? location,
    Value<String?>? notes,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return CalendarEventsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncVersion: syncVersion ?? this.syncVersion,
      createdOffline: createdOffline ?? this.createdOffline,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      type: type ?? this.type,
      date: date ?? this.date,
      time: time ?? this.time,
      subjectId: subjectId ?? this.subjectId,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (createdOffline.present) {
      map['created_offline'] = Variable<bool>(createdOffline.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (time.present) {
      map['time'] = Variable<String>(time.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEventsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('createdOffline: $createdOffline, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('date: $date, ')
          ..write('time: $time, ')
          ..write('subjectId: $subjectId, ')
          ..write('location: $location, ')
          ..write('notes: $notes, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LectureEvidenceTable extends LectureEvidence
    with TableInfo<$LectureEvidenceTable, LectureEvidenceEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LectureEvidenceTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lectureRecordIdMeta = const VerificationMeta(
    'lectureRecordId',
  );
  @override
  late final GeneratedColumn<String> lectureRecordId = GeneratedColumn<String>(
    'lecture_record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathRelativeMeta = const VerificationMeta(
    'localPathRelative',
  );
  @override
  late final GeneratedColumn<String> localPathRelative =
      GeneratedColumn<String>(
        'local_path_relative',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _captureTimestampMeta = const VerificationMeta(
    'captureTimestamp',
  );
  @override
  late final GeneratedColumn<DateTime> captureTimestamp =
      GeneratedColumn<DateTime>(
        'capture_timestamp',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _appVersionMeta = const VerificationMeta(
    'appVersion',
  );
  @override
  late final GeneratedColumn<String> appVersion = GeneratedColumn<String>(
    'app_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('original'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lectureRecordId,
    localPathRelative,
    sha256,
    width,
    height,
    captureTimestamp,
    appVersion,
    timezone,
    state,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lecture_evidence';
  @override
  VerificationContext validateIntegrity(
    Insertable<LectureEvidenceEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('lecture_record_id')) {
      context.handle(
        _lectureRecordIdMeta,
        lectureRecordId.isAcceptableOrUnknown(
          data['lecture_record_id']!,
          _lectureRecordIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lectureRecordIdMeta);
    }
    if (data.containsKey('local_path_relative')) {
      context.handle(
        _localPathRelativeMeta,
        localPathRelative.isAcceptableOrUnknown(
          data['local_path_relative']!,
          _localPathRelativeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localPathRelativeMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    if (data.containsKey('capture_timestamp')) {
      context.handle(
        _captureTimestampMeta,
        captureTimestamp.isAcceptableOrUnknown(
          data['capture_timestamp']!,
          _captureTimestampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_captureTimestampMeta);
    }
    if (data.containsKey('app_version')) {
      context.handle(
        _appVersionMeta,
        appVersion.isAcceptableOrUnknown(data['app_version']!, _appVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_appVersionMeta);
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    } else if (isInserting) {
      context.missing(_timezoneMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {lectureRecordId},
  ];
  @override
  LectureEvidenceEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LectureEvidenceEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      lectureRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lecture_record_id'],
      )!,
      localPathRelative: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path_relative'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      )!,
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      )!,
      captureTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}capture_timestamp'],
      )!,
      appVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_version'],
      )!,
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
    );
  }

  @override
  $LectureEvidenceTable createAlias(String alias) {
    return $LectureEvidenceTable(attachedDatabase, alias);
  }
}

class LectureEvidenceEntity extends DataClass
    implements Insertable<LectureEvidenceEntity> {
  /// UUID primary key.
  final String id;

  /// 1:1 link to the lecture record; UNIQUE enforces one evidence row
  /// per record.
  final String lectureRecordId;

  /// Path **relative** to the app documents directory (Phase 4 §A2).
  /// Resolve against `getApplicationDocumentsDirectory()` at runtime.
  final String localPathRelative;

  /// SHA-256 of the evidence file, re-verified on open/export (spec §10).
  final String sha256;

  /// Captured image width in pixels.
  final int width;

  /// Captured image height in pixels.
  final int height;

  /// UTC instant the evidence was captured.
  final DateTime captureTimestamp;

  /// App version that captured this evidence (spec §11).
  final String appVersion;

  /// Device timezone at capture (spec §11).
  final String timezone;

  /// Integrity state: `original` | `missing` | `integrity_failed` (spec §10).
  /// Defaults to `original`; the integrity verifier flips it on re-check.
  final String state;
  const LectureEvidenceEntity({
    required this.id,
    required this.lectureRecordId,
    required this.localPathRelative,
    required this.sha256,
    required this.width,
    required this.height,
    required this.captureTimestamp,
    required this.appVersion,
    required this.timezone,
    required this.state,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['lecture_record_id'] = Variable<String>(lectureRecordId);
    map['local_path_relative'] = Variable<String>(localPathRelative);
    map['sha256'] = Variable<String>(sha256);
    map['width'] = Variable<int>(width);
    map['height'] = Variable<int>(height);
    map['capture_timestamp'] = Variable<DateTime>(captureTimestamp);
    map['app_version'] = Variable<String>(appVersion);
    map['timezone'] = Variable<String>(timezone);
    map['state'] = Variable<String>(state);
    return map;
  }

  LectureEvidenceCompanion toCompanion(bool nullToAbsent) {
    return LectureEvidenceCompanion(
      id: Value(id),
      lectureRecordId: Value(lectureRecordId),
      localPathRelative: Value(localPathRelative),
      sha256: Value(sha256),
      width: Value(width),
      height: Value(height),
      captureTimestamp: Value(captureTimestamp),
      appVersion: Value(appVersion),
      timezone: Value(timezone),
      state: Value(state),
    );
  }

  factory LectureEvidenceEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LectureEvidenceEntity(
      id: serializer.fromJson<String>(json['id']),
      lectureRecordId: serializer.fromJson<String>(json['lectureRecordId']),
      localPathRelative: serializer.fromJson<String>(json['localPathRelative']),
      sha256: serializer.fromJson<String>(json['sha256']),
      width: serializer.fromJson<int>(json['width']),
      height: serializer.fromJson<int>(json['height']),
      captureTimestamp: serializer.fromJson<DateTime>(json['captureTimestamp']),
      appVersion: serializer.fromJson<String>(json['appVersion']),
      timezone: serializer.fromJson<String>(json['timezone']),
      state: serializer.fromJson<String>(json['state']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lectureRecordId': serializer.toJson<String>(lectureRecordId),
      'localPathRelative': serializer.toJson<String>(localPathRelative),
      'sha256': serializer.toJson<String>(sha256),
      'width': serializer.toJson<int>(width),
      'height': serializer.toJson<int>(height),
      'captureTimestamp': serializer.toJson<DateTime>(captureTimestamp),
      'appVersion': serializer.toJson<String>(appVersion),
      'timezone': serializer.toJson<String>(timezone),
      'state': serializer.toJson<String>(state),
    };
  }

  LectureEvidenceEntity copyWith({
    String? id,
    String? lectureRecordId,
    String? localPathRelative,
    String? sha256,
    int? width,
    int? height,
    DateTime? captureTimestamp,
    String? appVersion,
    String? timezone,
    String? state,
  }) => LectureEvidenceEntity(
    id: id ?? this.id,
    lectureRecordId: lectureRecordId ?? this.lectureRecordId,
    localPathRelative: localPathRelative ?? this.localPathRelative,
    sha256: sha256 ?? this.sha256,
    width: width ?? this.width,
    height: height ?? this.height,
    captureTimestamp: captureTimestamp ?? this.captureTimestamp,
    appVersion: appVersion ?? this.appVersion,
    timezone: timezone ?? this.timezone,
    state: state ?? this.state,
  );
  LectureEvidenceEntity copyWithCompanion(LectureEvidenceCompanion data) {
    return LectureEvidenceEntity(
      id: data.id.present ? data.id.value : this.id,
      lectureRecordId: data.lectureRecordId.present
          ? data.lectureRecordId.value
          : this.lectureRecordId,
      localPathRelative: data.localPathRelative.present
          ? data.localPathRelative.value
          : this.localPathRelative,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      captureTimestamp: data.captureTimestamp.present
          ? data.captureTimestamp.value
          : this.captureTimestamp,
      appVersion: data.appVersion.present
          ? data.appVersion.value
          : this.appVersion,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      state: data.state.present ? data.state.value : this.state,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LectureEvidenceEntity(')
          ..write('id: $id, ')
          ..write('lectureRecordId: $lectureRecordId, ')
          ..write('localPathRelative: $localPathRelative, ')
          ..write('sha256: $sha256, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('captureTimestamp: $captureTimestamp, ')
          ..write('appVersion: $appVersion, ')
          ..write('timezone: $timezone, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lectureRecordId,
    localPathRelative,
    sha256,
    width,
    height,
    captureTimestamp,
    appVersion,
    timezone,
    state,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LectureEvidenceEntity &&
          other.id == this.id &&
          other.lectureRecordId == this.lectureRecordId &&
          other.localPathRelative == this.localPathRelative &&
          other.sha256 == this.sha256 &&
          other.width == this.width &&
          other.height == this.height &&
          other.captureTimestamp == this.captureTimestamp &&
          other.appVersion == this.appVersion &&
          other.timezone == this.timezone &&
          other.state == this.state);
}

class LectureEvidenceCompanion extends UpdateCompanion<LectureEvidenceEntity> {
  final Value<String> id;
  final Value<String> lectureRecordId;
  final Value<String> localPathRelative;
  final Value<String> sha256;
  final Value<int> width;
  final Value<int> height;
  final Value<DateTime> captureTimestamp;
  final Value<String> appVersion;
  final Value<String> timezone;
  final Value<String> state;
  final Value<int> rowid;
  const LectureEvidenceCompanion({
    this.id = const Value.absent(),
    this.lectureRecordId = const Value.absent(),
    this.localPathRelative = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.captureTimestamp = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.timezone = const Value.absent(),
    this.state = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LectureEvidenceCompanion.insert({
    required String id,
    required String lectureRecordId,
    required String localPathRelative,
    required String sha256,
    required int width,
    required int height,
    required DateTime captureTimestamp,
    required String appVersion,
    required String timezone,
    this.state = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       lectureRecordId = Value(lectureRecordId),
       localPathRelative = Value(localPathRelative),
       sha256 = Value(sha256),
       width = Value(width),
       height = Value(height),
       captureTimestamp = Value(captureTimestamp),
       appVersion = Value(appVersion),
       timezone = Value(timezone);
  static Insertable<LectureEvidenceEntity> custom({
    Expression<String>? id,
    Expression<String>? lectureRecordId,
    Expression<String>? localPathRelative,
    Expression<String>? sha256,
    Expression<int>? width,
    Expression<int>? height,
    Expression<DateTime>? captureTimestamp,
    Expression<String>? appVersion,
    Expression<String>? timezone,
    Expression<String>? state,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lectureRecordId != null) 'lecture_record_id': lectureRecordId,
      if (localPathRelative != null) 'local_path_relative': localPathRelative,
      if (sha256 != null) 'sha256': sha256,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (captureTimestamp != null) 'capture_timestamp': captureTimestamp,
      if (appVersion != null) 'app_version': appVersion,
      if (timezone != null) 'timezone': timezone,
      if (state != null) 'state': state,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LectureEvidenceCompanion copyWith({
    Value<String>? id,
    Value<String>? lectureRecordId,
    Value<String>? localPathRelative,
    Value<String>? sha256,
    Value<int>? width,
    Value<int>? height,
    Value<DateTime>? captureTimestamp,
    Value<String>? appVersion,
    Value<String>? timezone,
    Value<String>? state,
    Value<int>? rowid,
  }) {
    return LectureEvidenceCompanion(
      id: id ?? this.id,
      lectureRecordId: lectureRecordId ?? this.lectureRecordId,
      localPathRelative: localPathRelative ?? this.localPathRelative,
      sha256: sha256 ?? this.sha256,
      width: width ?? this.width,
      height: height ?? this.height,
      captureTimestamp: captureTimestamp ?? this.captureTimestamp,
      appVersion: appVersion ?? this.appVersion,
      timezone: timezone ?? this.timezone,
      state: state ?? this.state,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lectureRecordId.present) {
      map['lecture_record_id'] = Variable<String>(lectureRecordId.value);
    }
    if (localPathRelative.present) {
      map['local_path_relative'] = Variable<String>(localPathRelative.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (captureTimestamp.present) {
      map['capture_timestamp'] = Variable<DateTime>(captureTimestamp.value);
    }
    if (appVersion.present) {
      map['app_version'] = Variable<String>(appVersion.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LectureEvidenceCompanion(')
          ..write('id: $id, ')
          ..write('lectureRecordId: $lectureRecordId, ')
          ..write('localPathRelative: $localPathRelative, ')
          ..write('sha256: $sha256, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('captureTimestamp: $captureTimestamp, ')
          ..write('appVersion: $appVersion, ')
          ..write('timezone: $timezone, ')
          ..write('state: $state, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, UserEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profilePhotoMeta = const VerificationMeta(
    'profilePhoto',
  );
  @override
  late final GeneratedColumn<String> profilePhoto = GeneratedColumn<String>(
    'profile_photo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    email,
    profilePhoto,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserEntity> instance, {
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
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('profile_photo')) {
      context.handle(
        _profilePhotoMeta,
        profilePhoto.isAcceptableOrUnknown(
          data['profile_photo']!,
          _profilePhotoMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      profilePhoto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_photo'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UserEntity extends DataClass implements Insertable<UserEntity> {
  /// Supabase user ID (text, not UUID).
  final String id;

  /// User's display name from Google account.
  final String name;

  /// User's email address from Google account.
  final String email;

  /// Google profile photo URL. Nullable.
  final String? profilePhoto;

  /// UTC creation timestamp.
  final DateTime createdAt;

  /// UTC last-modified timestamp.
  final DateTime updatedAt;
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.profilePhoto,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || profilePhoto != null) {
      map['profile_photo'] = Variable<String>(profilePhoto);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      profilePhoto: profilePhoto == null && nullToAbsent
          ? const Value.absent()
          : Value(profilePhoto),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserEntity(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      profilePhoto: serializer.fromJson<String?>(json['profilePhoto']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'profilePhoto': serializer.toJson<String?>(profilePhoto),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    Value<String?> profilePhoto = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    profilePhoto: profilePhoto.present ? profilePhoto.value : this.profilePhoto,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserEntity copyWithCompanion(UsersCompanion data) {
    return UserEntity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      profilePhoto: data.profilePhoto.present
          ? data.profilePhoto.value
          : this.profilePhoto,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserEntity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('profilePhoto: $profilePhoto, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, email, profilePhoto, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserEntity &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.profilePhoto == this.profilePhoto &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersCompanion extends UpdateCompanion<UserEntity> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> email;
  final Value<String?> profilePhoto;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.profilePhoto = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String name,
    required String email,
    this.profilePhoto = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       email = Value(email);
  static Insertable<UserEntity> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? profilePhoto,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (profilePhoto != null) 'profile_photo': profilePhoto,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? email,
    Value<String?>? profilePhoto,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (profilePhoto.present) {
      map['profile_photo'] = Variable<String>(profilePhoto.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('profilePhoto: $profilePhoto, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueItemsTable extends SyncQueueItems
    with TableInfo<$SyncQueueItemsTable, SyncQueueItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastAttemptMeta = const VerificationMeta(
    'lastAttempt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttempt = GeneratedColumn<DateTime>(
    'last_attempt',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recordId,
    operation,
    retryCount,
    createdAt,
    lastAttempt,
    error,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('last_attempt')) {
      context.handle(
        _lastAttemptMeta,
        lastAttempt.isAcceptableOrUnknown(
          data['last_attempt']!,
          _lastAttemptMeta,
        ),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastAttempt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt'],
      ),
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $SyncQueueItemsTable createAlias(String alias) {
    return $SyncQueueItemsTable(attachedDatabase, alias);
  }
}

class SyncQueueItem extends DataClass implements Insertable<SyncQueueItem> {
  /// Auto-incrementing primary key.
  final int id;

  /// The UUID of the record in the business table.
  final String recordId;

  /// The operation type: 'INSERT', 'UPDATE', or 'DELETE'.
  final String operation;

  /// Number of sync attempts (starts at 0).
  final int retryCount;

  /// UTC creation timestamp.
  final DateTime createdAt;

  /// UTC timestamp of the last attempt, or NULL if never attempted.
  final DateTime? lastAttempt;

  /// Error message if the last attempt failed.
  final String? error;

  /// Whether the operation has been synced.
  final bool isSynced;
  const SyncQueueItem({
    required this.id,
    required this.recordId,
    required this.operation,
    required this.retryCount,
    required this.createdAt,
    this.lastAttempt,
    this.error,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['record_id'] = Variable<String>(recordId);
    map['operation'] = Variable<String>(operation);
    map['retry_count'] = Variable<int>(retryCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastAttempt != null) {
      map['last_attempt'] = Variable<DateTime>(lastAttempt);
    }
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  SyncQueueItemsCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueItemsCompanion(
      id: Value(id),
      recordId: Value(recordId),
      operation: Value(operation),
      retryCount: Value(retryCount),
      createdAt: Value(createdAt),
      lastAttempt: lastAttempt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttempt),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
      isSynced: Value(isSynced),
    );
  }

  factory SyncQueueItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueItem(
      id: serializer.fromJson<int>(json['id']),
      recordId: serializer.fromJson<String>(json['recordId']),
      operation: serializer.fromJson<String>(json['operation']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastAttempt: serializer.fromJson<DateTime?>(json['lastAttempt']),
      error: serializer.fromJson<String?>(json['error']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recordId': serializer.toJson<String>(recordId),
      'operation': serializer.toJson<String>(operation),
      'retryCount': serializer.toJson<int>(retryCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastAttempt': serializer.toJson<DateTime?>(lastAttempt),
      'error': serializer.toJson<String?>(error),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  SyncQueueItem copyWith({
    int? id,
    String? recordId,
    String? operation,
    int? retryCount,
    DateTime? createdAt,
    Value<DateTime?> lastAttempt = const Value.absent(),
    Value<String?> error = const Value.absent(),
    bool? isSynced,
  }) => SyncQueueItem(
    id: id ?? this.id,
    recordId: recordId ?? this.recordId,
    operation: operation ?? this.operation,
    retryCount: retryCount ?? this.retryCount,
    createdAt: createdAt ?? this.createdAt,
    lastAttempt: lastAttempt.present ? lastAttempt.value : this.lastAttempt,
    error: error.present ? error.value : this.error,
    isSynced: isSynced ?? this.isSynced,
  );
  SyncQueueItem copyWithCompanion(SyncQueueItemsCompanion data) {
    return SyncQueueItem(
      id: data.id.present ? data.id.value : this.id,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      operation: data.operation.present ? data.operation.value : this.operation,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastAttempt: data.lastAttempt.present
          ? data.lastAttempt.value
          : this.lastAttempt,
      error: data.error.present ? data.error.value : this.error,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueItem(')
          ..write('id: $id, ')
          ..write('recordId: $recordId, ')
          ..write('operation: $operation, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttempt: $lastAttempt, ')
          ..write('error: $error, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    recordId,
    operation,
    retryCount,
    createdAt,
    lastAttempt,
    error,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueItem &&
          other.id == this.id &&
          other.recordId == this.recordId &&
          other.operation == this.operation &&
          other.retryCount == this.retryCount &&
          other.createdAt == this.createdAt &&
          other.lastAttempt == this.lastAttempt &&
          other.error == this.error &&
          other.isSynced == this.isSynced);
}

class SyncQueueItemsCompanion extends UpdateCompanion<SyncQueueItem> {
  final Value<int> id;
  final Value<String> recordId;
  final Value<String> operation;
  final Value<int> retryCount;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastAttempt;
  final Value<String?> error;
  final Value<bool> isSynced;
  const SyncQueueItemsCompanion({
    this.id = const Value.absent(),
    this.recordId = const Value.absent(),
    this.operation = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastAttempt = const Value.absent(),
    this.error = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  SyncQueueItemsCompanion.insert({
    this.id = const Value.absent(),
    required String recordId,
    required String operation,
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastAttempt = const Value.absent(),
    this.error = const Value.absent(),
    this.isSynced = const Value.absent(),
  }) : recordId = Value(recordId),
       operation = Value(operation);
  static Insertable<SyncQueueItem> custom({
    Expression<int>? id,
    Expression<String>? recordId,
    Expression<String>? operation,
    Expression<int>? retryCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastAttempt,
    Expression<String>? error,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recordId != null) 'record_id': recordId,
      if (operation != null) 'operation': operation,
      if (retryCount != null) 'retry_count': retryCount,
      if (createdAt != null) 'created_at': createdAt,
      if (lastAttempt != null) 'last_attempt': lastAttempt,
      if (error != null) 'error': error,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  SyncQueueItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? recordId,
    Value<String>? operation,
    Value<int>? retryCount,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastAttempt,
    Value<String?>? error,
    Value<bool>? isSynced,
  }) {
    return SyncQueueItemsCompanion(
      id: id ?? this.id,
      recordId: recordId ?? this.recordId,
      operation: operation ?? this.operation,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
      lastAttempt: lastAttempt ?? this.lastAttempt,
      error: error ?? this.error,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastAttempt.present) {
      map['last_attempt'] = Variable<DateTime>(lastAttempt.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueItemsCompanion(')
          ..write('id: $id, ')
          ..write('recordId: $recordId, ')
          ..write('operation: $operation, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttempt: $lastAttempt, ')
          ..write('error: $error, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTable extends SyncMetadata
    with TableInfo<$SyncMetadataTable, SyncMetadataEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetadataEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncMetadataEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataEntity(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SyncMetadataTable createAlias(String alias) {
    return $SyncMetadataTable(attachedDatabase, alias);
  }
}

class SyncMetadataEntity extends DataClass
    implements Insertable<SyncMetadataEntity> {
  /// Stable bookkeeping key (e.g. "pull_cursor:timetable",
  /// "last_pull_at").
  final String key;

  /// Bookkeeping value (opaque to the schema).
  final String? value;

  /// When this row was last updated.
  final DateTime updatedAt;
  const SyncMetadataEntity({
    required this.key,
    this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncMetadataEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataEntity(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncMetadataEntity copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
    DateTime? updatedAt,
  }) => SyncMetadataEntity(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SyncMetadataEntity copyWithCompanion(SyncMetadataCompanion data) {
    return SyncMetadataEntity(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataEntity(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadataEntity &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class SyncMetadataCompanion extends UpdateCompanion<SyncMetadataEntity> {
  final Value<String> key;
  final Value<String?> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SyncMetadataCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadataCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       updatedAt = Value(updatedAt);
  static Insertable<SyncMetadataEntity> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetadataCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SyncMetadataCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SemestersTable semesters = $SemestersTable(this);
  late final $SubjectsTable subjects = $SubjectsTable(this);
  late final $TimetableTable timetable = $TimetableTable(this);
  late final $LectureRecordsTable lectureRecords = $LectureRecordsTable(this);
  late final $AssignmentsTable assignments = $AssignmentsTable(this);
  late final $InternalMarksTable internalMarks = $InternalMarksTable(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  late final $CalendarEventsTable calendarEvents = $CalendarEventsTable(this);
  late final $LectureEvidenceTable lectureEvidence = $LectureEvidenceTable(
    this,
  );
  late final $UsersTable users = $UsersTable(this);
  late final $SyncQueueItemsTable syncQueueItems = $SyncQueueItemsTable(this);
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  late final Index idxSyncQueueRecordId = Index(
    'idx_sync_queue_record_id',
    'CREATE INDEX idx_sync_queue_record_id ON sync_queue (record_id)',
  );
  late final Index idxSyncQueueOperation = Index(
    'idx_sync_queue_operation',
    'CREATE INDEX idx_sync_queue_operation ON sync_queue (operation)',
  );
  late final Index idxSyncQueueStatus = Index(
    'idx_sync_queue_status',
    'CREATE INDEX idx_sync_queue_status ON sync_queue (is_synced)',
  );
  late final Index idxSyncQueuePending = Index(
    'idx_sync_queue_pending',
    'CREATE INDEX idx_sync_queue_pending ON sync_queue (record_id, is_synced, retry_count)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    semesters,
    subjects,
    timetable,
    lectureRecords,
    assignments,
    internalMarks,
    userSettings,
    calendarEvents,
    lectureEvidence,
    users,
    syncQueueItems,
    syncMetadata,
    idxSyncQueueRecordId,
    idxSyncQueueOperation,
    idxSyncQueueStatus,
    idxSyncQueuePending,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$SemestersTableCreateCompanionBuilder =
    SemestersCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> syncVersion,
      Value<bool> createdOffline,
      Value<DateTime?> lastSyncedAt,
      required String id,
      required String userId,
      required String name,
      required String workingDays,
      Value<bool> isCurrent,
      Value<bool> isArchived,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$SemestersTableUpdateCompanionBuilder =
    SemestersCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> syncVersion,
      Value<bool> createdOffline,
      Value<DateTime?> lastSyncedAt,
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<String> workingDays,
      Value<bool> isCurrent,
      Value<bool> isArchived,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$SemestersTableFilterComposer
    extends Composer<_$AppDatabase, $SemestersTable> {
  $$SemestersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get createdOffline => $composableBuilder(
    column: $table.createdOffline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workingDays => $composableBuilder(
    column: $table.workingDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCurrent => $composableBuilder(
    column: $table.isCurrent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SemestersTableOrderingComposer
    extends Composer<_$AppDatabase, $SemestersTable> {
  $$SemestersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get createdOffline => $composableBuilder(
    column: $table.createdOffline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workingDays => $composableBuilder(
    column: $table.workingDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCurrent => $composableBuilder(
    column: $table.isCurrent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SemestersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SemestersTable> {
  $$SemestersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get createdOffline => $composableBuilder(
    column: $table.createdOffline,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get workingDays => $composableBuilder(
    column: $table.workingDays,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCurrent =>
      $composableBuilder(column: $table.isCurrent, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$SemestersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SemestersTable,
          SemesterEntity,
          $$SemestersTableFilterComposer,
          $$SemestersTableOrderingComposer,
          $$SemestersTableAnnotationComposer,
          $$SemestersTableCreateCompanionBuilder,
          $$SemestersTableUpdateCompanionBuilder,
          (
            SemesterEntity,
            BaseReferences<_$AppDatabase, $SemestersTable, SemesterEntity>,
          ),
          SemesterEntity,
          PrefetchHooks Function()
        > {
  $$SemestersTableTableManager(_$AppDatabase db, $SemestersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SemestersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SemestersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SemestersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> createdOffline = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> workingDays = const Value.absent(),
                Value<bool> isCurrent = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SemestersCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                syncVersion: syncVersion,
                createdOffline: createdOffline,
                lastSyncedAt: lastSyncedAt,
                id: id,
                userId: userId,
                name: name,
                workingDays: workingDays,
                isCurrent: isCurrent,
                isArchived: isArchived,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> createdOffline = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                required String id,
                required String userId,
                required String name,
                required String workingDays,
                Value<bool> isCurrent = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SemestersCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                syncVersion: syncVersion,
                createdOffline: createdOffline,
                lastSyncedAt: lastSyncedAt,
                id: id,
                userId: userId,
                name: name,
                workingDays: workingDays,
                isCurrent: isCurrent,
                isArchived: isArchived,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SemestersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SemestersTable,
      SemesterEntity,
      $$SemestersTableFilterComposer,
      $$SemestersTableOrderingComposer,
      $$SemestersTableAnnotationComposer,
      $$SemestersTableCreateCompanionBuilder,
      $$SemestersTableUpdateCompanionBuilder,
      (
        SemesterEntity,
        BaseReferences<_$AppDatabase, $SemestersTable, SemesterEntity>,
      ),
      SemesterEntity,
      PrefetchHooks Function()
    >;
typedef $$SubjectsTableCreateCompanionBuilder =
    SubjectsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> syncVersion,
      Value<bool> createdOffline,
      Value<DateTime?> lastSyncedAt,
      required String id,
      required String userId,
      required String semesterId,
      required String name,
      Value<String?> faculty,
      Value<String> type,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$SubjectsTableUpdateCompanionBuilder =
    SubjectsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> syncVersion,
      Value<bool> createdOffline,
      Value<DateTime?> lastSyncedAt,
      Value<String> id,
      Value<String> userId,
      Value<String> semesterId,
      Value<String> name,
      Value<String?> faculty,
      Value<String> type,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$SubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get createdOffline => $composableBuilder(
    column: $table.createdOffline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get semesterId => $composableBuilder(
    column: $table.semesterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get faculty => $composableBuilder(
    column: $table.faculty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SubjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get createdOffline => $composableBuilder(
    column: $table.createdOffline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get semesterId => $composableBuilder(
    column: $table.semesterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get faculty => $composableBuilder(
    column: $table.faculty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get createdOffline => $composableBuilder(
    column: $table.createdOffline,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get semesterId => $composableBuilder(
    column: $table.semesterId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get faculty =>
      $composableBuilder(column: $table.faculty, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$SubjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubjectsTable,
          SubjectEntity,
          $$SubjectsTableFilterComposer,
          $$SubjectsTableOrderingComposer,
          $$SubjectsTableAnnotationComposer,
          $$SubjectsTableCreateCompanionBuilder,
          $$SubjectsTableUpdateCompanionBuilder,
          (
            SubjectEntity,
            BaseReferences<_$AppDatabase, $SubjectsTable, SubjectEntity>,
          ),
          SubjectEntity,
          PrefetchHooks Function()
        > {
  $$SubjectsTableTableManager(_$AppDatabase db, $SubjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> createdOffline = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> semesterId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> faculty = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubjectsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                syncVersion: syncVersion,
                createdOffline: createdOffline,
                lastSyncedAt: lastSyncedAt,
                id: id,
                userId: userId,
                semesterId: semesterId,
                name: name,
                faculty: faculty,
                type: type,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> createdOffline = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                required String id,
                required String userId,
                required String semesterId,
                required String name,
                Value<String?> faculty = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubjectsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                syncVersion: syncVersion,
                createdOffline: createdOffline,
                lastSyncedAt: lastSyncedAt,
                id: id,
                userId: userId,
                semesterId: semesterId,
                name: name,
                faculty: faculty,
                type: type,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubjectsTable,
      SubjectEntity,
      $$SubjectsTableFilterComposer,
      $$SubjectsTableOrderingComposer,
      $$SubjectsTableAnnotationComposer,
      $$SubjectsTableCreateCompanionBuilder,
      $$SubjectsTableUpdateCompanionBuilder,
      (
        SubjectEntity,
        BaseReferences<_$AppDatabase, $SubjectsTable, SubjectEntity>,
      ),
      SubjectEntity,
      PrefetchHooks Function()
    >;
typedef $$TimetableTableCreateCompanionBuilder =
    TimetableCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> syncVersion,
      Value<bool> createdOffline,
      Value<DateTime?> lastSyncedAt,
      required String id,
      required String userId,
      required String subjectId,
      required int dayOfWeek,
      required String startTime,
      required String endTime,
      Value<String?> room,
      Value<String> lectureType,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$TimetableTableUpdateCompanionBuilder =
    TimetableCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> syncVersion,
      Value<bool> createdOffline,
      Value<DateTime?> lastSyncedAt,
      Value<String> id,
      Value<String> userId,
      Value<String> subjectId,
      Value<int> dayOfWeek,
      Value<String> startTime,
      Value<String> endTime,
      Value<String?> room,
      Value<String> lectureType,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$TimetableTableFilterComposer
    extends Composer<_$AppDatabase, $TimetableTable> {
  $$TimetableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get createdOffline => $composableBuilder(
    column: $table.createdOffline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get room => $composableBuilder(
    column: $table.room,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lectureType => $composableBuilder(
    column: $table.lectureType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TimetableTableOrderingComposer
    extends Composer<_$AppDatabase, $TimetableTable> {
  $$TimetableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get createdOffline => $composableBuilder(
    column: $table.createdOffline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get room => $composableBuilder(
    column: $table.room,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lectureType => $composableBuilder(
    column: $table.lectureType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimetableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimetableTable> {
  $$TimetableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get createdOffline => $composableBuilder(
    column: $table.createdOffline,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<int> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get room =>
      $composableBuilder(column: $table.room, builder: (column) => column);

  GeneratedColumn<String> get lectureType => $composableBuilder(
    column: $table.lectureType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$TimetableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimetableTable,
          TimetableEntryEntity,
          $$TimetableTableFilterComposer,
          $$TimetableTableOrderingComposer,
          $$TimetableTableAnnotationComposer,
          $$TimetableTableCreateCompanionBuilder,
          $$TimetableTableUpdateCompanionBuilder,
          (
            TimetableEntryEntity,
            BaseReferences<
              _$AppDatabase,
              $TimetableTable,
              TimetableEntryEntity
            >,
          ),
          TimetableEntryEntity,
          PrefetchHooks Function()
        > {
  $$TimetableTableTableManager(_$AppDatabase db, $TimetableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimetableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimetableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimetableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> createdOffline = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> subjectId = const Value.absent(),
                Value<int> dayOfWeek = const Value.absent(),
                Value<String> startTime = const Value.absent(),
                Value<String> endTime = const Value.absent(),
                Value<String?> room = const Value.absent(),
                Value<String> lectureType = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimetableCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                syncVersion: syncVersion,
                createdOffline: createdOffline,
                lastSyncedAt: lastSyncedAt,
                id: id,
                userId: userId,
                subjectId: subjectId,
                dayOfWeek: dayOfWeek,
                startTime: startTime,
                endTime: endTime,
                room: room,
                lectureType: lectureType,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> createdOffline = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                required String id,
                required String userId,
                required String subjectId,
                required int dayOfWeek,
                required String startTime,
                required String endTime,
                Value<String?> room = const Value.absent(),
                Value<String> lectureType = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimetableCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                syncVersion: syncVersion,
                createdOffline: createdOffline,
                lastSyncedAt: lastSyncedAt,
                id: id,
                userId: userId,
                subjectId: subjectId,
                dayOfWeek: dayOfWeek,
                startTime: startTime,
                endTime: endTime,
                room: room,
                lectureType: lectureType,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TimetableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimetableTable,
      TimetableEntryEntity,
      $$TimetableTableFilterComposer,
      $$TimetableTableOrderingComposer,
      $$TimetableTableAnnotationComposer,
      $$TimetableTableCreateCompanionBuilder,
      $$TimetableTableUpdateCompanionBuilder,
      (
        TimetableEntryEntity,
        BaseReferences<_$AppDatabase, $TimetableTable, TimetableEntryEntity>,
      ),
      TimetableEntryEntity,
      PrefetchHooks Function()
    >;
typedef $$LectureRecordsTableCreateCompanionBuilder =
    LectureRecordsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> syncVersion,
      Value<bool> createdOffline,
      Value<DateTime?> lastSyncedAt,
      required String id,
      required String timetableId,
      required String subjectId,
      required String semesterId,
      required String userId,
      required String statusText,
      Value<String?> note,
      required DateTime recordedAt,
      required String deviceTimezone,
      required String appVersion,
      Value<int> rowid,
    });
typedef $$LectureRecordsTableUpdateCompanionBuilder =
    LectureRecordsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> syncVersion,
      Value<bool> createdOffline,
      Value<DateTime?> lastSyncedAt,
      Value<String> id,
      Value<String> timetableId,
      Value<String> subjectId,
      Value<String> semesterId,
      Value<String> userId,
      Value<String> statusText,
      Value<String?> note,
      Value<DateTime> recordedAt,
      Value<String> deviceTimezone,
      Value<String> appVersion,
      Value<int> rowid,
    });

class $$LectureRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $LectureRecordsTable> {
  $$LectureRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get createdOffline => $composableBuilder(
    column: $table.createdOffline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timetableId => $composableBuilder(
    column: $table.timetableId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get semesterId => $composableBuilder(
    column: $table.semesterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusText => $composableBuilder(
    column: $table.statusText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceTimezone => $composableBuilder(
    column: $table.deviceTimezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LectureRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $LectureRecordsTable> {
  $$LectureRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get createdOffline => $composableBuilder(
    column: $table.createdOffline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timetableId => $composableBuilder(
    column: $table.timetableId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get semesterId => $composableBuilder(
    column: $table.semesterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusText => $composableBuilder(
    column: $table.statusText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceTimezone => $composableBuilder(
    column: $table.deviceTimezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LectureRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LectureRecordsTable> {
  $$LectureRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get createdOffline => $composableBuilder(
    column: $table.createdOffline,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get timetableId => $composableBuilder(
    column: $table.timetableId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get semesterId => $composableBuilder(
    column: $table.semesterId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get statusText => $composableBuilder(
    column: $table.statusText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceTimezone => $composableBuilder(
    column: $table.deviceTimezone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => column,
  );
}

class $$LectureRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LectureRecordsTable,
          LectureRecordEntity,
          $$LectureRecordsTableFilterComposer,
          $$LectureRecordsTableOrderingComposer,
          $$LectureRecordsTableAnnotationComposer,
          $$LectureRecordsTableCreateCompanionBuilder,
          $$LectureRecordsTableUpdateCompanionBuilder,
          (
            LectureRecordEntity,
            BaseReferences<
              _$AppDatabase,
              $LectureRecordsTable,
              LectureRecordEntity
            >,
          ),
          LectureRecordEntity,
          PrefetchHooks Function()
        > {
  $$LectureRecordsTableTableManager(
    _$AppDatabase db,
    $LectureRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LectureRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LectureRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LectureRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> createdOffline = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> timetableId = const Value.absent(),
                Value<String> subjectId = const Value.absent(),
                Value<String> semesterId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> statusText = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<String> deviceTimezone = const Value.absent(),
                Value<String> appVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LectureRecordsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                syncVersion: syncVersion,
                createdOffline: createdOffline,
                lastSyncedAt: lastSyncedAt,
                id: id,
                timetableId: timetableId,
                subjectId: subjectId,
                semesterId: semesterId,
                userId: userId,
                statusText: statusText,
                note: note,
                recordedAt: recordedAt,
                deviceTimezone: deviceTimezone,
                appVersion: appVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> createdOffline = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                required String id,
                required String timetableId,
                required String subjectId,
                required String semesterId,
                required String userId,
                required String statusText,
                Value<String?> note = const Value.absent(),
                required DateTime recordedAt,
                required String deviceTimezone,
                required String appVersion,
                Value<int> rowid = const Value.absent(),
              }) => LectureRecordsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                syncVersion: syncVersion,
                createdOffline: createdOffline,
                lastSyncedAt: lastSyncedAt,
                id: id,
                timetableId: timetableId,
                subjectId: subjectId,
                semesterId: semesterId,
                userId: userId,
                statusText: statusText,
                note: note,
                recordedAt: recordedAt,
                deviceTimezone: deviceTimezone,
                appVersion: appVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LectureRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LectureRecordsTable,
      LectureRecordEntity,
      $$LectureRecordsTableFilterComposer,
      $$LectureRecordsTableOrderingComposer,
      $$LectureRecordsTableAnnotationComposer,
      $$LectureRecordsTableCreateCompanionBuilder,
      $$LectureRecordsTableUpdateCompanionBuilder,
      (
        LectureRecordEntity,
        BaseReferences<
          _$AppDatabase,
          $LectureRecordsTable,
          LectureRecordEntity
        >,
      ),
      LectureRecordEntity,
      PrefetchHooks Function()
    >;
typedef $$AssignmentsTableCreateCompanionBuilder =
    AssignmentsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> syncVersion,
      Value<bool> createdOffline,
      Value<DateTime?> lastSyncedAt,
      required String id,
      required String userId,
      required String subjectId,
      required String title,
      Value<String?> description,
      required String dueDate,
      Value<String> status,
      Value<DateTime?> completedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$AssignmentsTableUpdateCompanionBuilder =
    AssignmentsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> syncVersion,
      Value<bool> createdOffline,
      Value<DateTime?> lastSyncedAt,
      Value<String> id,
      Value<String> userId,
      Value<String> subjectId,
      Value<String> title,
      Value<String?> description,
      Value<String> dueDate,
      Value<String> status,
      Value<DateTime?> completedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$AssignmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AssignmentsTable> {
  $$AssignmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get createdOffline => $composableBuilder(
    column: $table.createdOffline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AssignmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssignmentsTable> {
  $$AssignmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get createdOffline => $composableBuilder(
    column: $table.createdOffline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssignmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssignmentsTable> {
  $$AssignmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get createdOffline => $composableBuilder(
    column: $table.createdOffline,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$AssignmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssignmentsTable,
          AssignmentEntity,
          $$AssignmentsTableFilterComposer,
          $$AssignmentsTableOrderingComposer,
          $$AssignmentsTableAnnotationComposer,
          $$AssignmentsTableCreateCompanionBuilder,
          $$AssignmentsTableUpdateCompanionBuilder,
          (
            AssignmentEntity,
            BaseReferences<_$AppDatabase, $AssignmentsTable, AssignmentEntity>,
          ),
          AssignmentEntity,
          PrefetchHooks Function()
        > {
  $$AssignmentsTableTableManager(_$AppDatabase db, $AssignmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssignmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssignmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssignmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> createdOffline = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> subjectId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> dueDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssignmentsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                syncVersion: syncVersion,
                createdOffline: createdOffline,
                lastSyncedAt: lastSyncedAt,
                id: id,
                userId: userId,
                subjectId: subjectId,
                title: title,
                description: description,
                dueDate: dueDate,
                status: status,
                completedAt: completedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> createdOffline = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                required String id,
                required String userId,
                required String subjectId,
                required String title,
                Value<String?> description = const Value.absent(),
                required String dueDate,
                Value<String> status = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssignmentsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                syncVersion: syncVersion,
                createdOffline: createdOffline,
                lastSyncedAt: lastSyncedAt,
                id: id,
                userId: userId,
                subjectId: subjectId,
                title: title,
                description: description,
                dueDate: dueDate,
                status: status,
                completedAt: completedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AssignmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssignmentsTable,
      AssignmentEntity,
      $$AssignmentsTableFilterComposer,
      $$AssignmentsTableOrderingComposer,
      $$AssignmentsTableAnnotationComposer,
      $$AssignmentsTableCreateCompanionBuilder,
      $$AssignmentsTableUpdateCompanionBuilder,
      (
        AssignmentEntity,
        BaseReferences<_$AppDatabase, $AssignmentsTable, AssignmentEntity>,
      ),
      AssignmentEntity,
      PrefetchHooks Function()
    >;
typedef $$InternalMarksTableCreateCompanionBuilder =
    InternalMarksCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> syncVersion,
      Value<bool> createdOffline,
      Value<DateTime?> lastSyncedAt,
      required String id,
      required String userId,
      required String subjectId,
      required String examName,
      required double marksObtained,
      required double maxMarks,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$InternalMarksTableUpdateCompanionBuilder =
    InternalMarksCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> syncVersion,
      Value<bool> createdOffline,
      Value<DateTime?> lastSyncedAt,
      Value<String> id,
      Value<String> userId,
      Value<String> subjectId,
      Value<String> examName,
      Value<double> marksObtained,
      Value<double> maxMarks,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$InternalMarksTableFilterComposer
    extends Composer<_$AppDatabase, $InternalMarksTable> {
  $$InternalMarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get createdOffline => $composableBuilder(
    column: $table.createdOffline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get examName => $composableBuilder(
    column: $table.examName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get marksObtained => $composableBuilder(
    column: $table.marksObtained,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxMarks => $composableBuilder(
    column: $table.maxMarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InternalMarksTableOrderingComposer
    extends Composer<_$AppDatabase, $InternalMarksTable> {
  $$InternalMarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get createdOffline => $composableBuilder(
    column: $table.createdOffline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get examName => $composableBuilder(
    column: $table.examName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get marksObtained => $composableBuilder(
    column: $table.marksObtained,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxMarks => $composableBuilder(
    column: $table.maxMarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InternalMarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $InternalMarksTable> {
  $$InternalMarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get createdOffline => $composableBuilder(
    column: $table.createdOffline,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get examName =>
      $composableBuilder(column: $table.examName, builder: (column) => column);

  GeneratedColumn<double> get marksObtained => $composableBuilder(
    column: $table.marksObtained,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxMarks =>
      $composableBuilder(column: $table.maxMarks, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$InternalMarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InternalMarksTable,
          InternalMarkEntity,
          $$InternalMarksTableFilterComposer,
          $$InternalMarksTableOrderingComposer,
          $$InternalMarksTableAnnotationComposer,
          $$InternalMarksTableCreateCompanionBuilder,
          $$InternalMarksTableUpdateCompanionBuilder,
          (
            InternalMarkEntity,
            BaseReferences<
              _$AppDatabase,
              $InternalMarksTable,
              InternalMarkEntity
            >,
          ),
          InternalMarkEntity,
          PrefetchHooks Function()
        > {
  $$InternalMarksTableTableManager(_$AppDatabase db, $InternalMarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InternalMarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InternalMarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InternalMarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> createdOffline = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> subjectId = const Value.absent(),
                Value<String> examName = const Value.absent(),
                Value<double> marksObtained = const Value.absent(),
                Value<double> maxMarks = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InternalMarksCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                syncVersion: syncVersion,
                createdOffline: createdOffline,
                lastSyncedAt: lastSyncedAt,
                id: id,
                userId: userId,
                subjectId: subjectId,
                examName: examName,
                marksObtained: marksObtained,
                maxMarks: maxMarks,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> createdOffline = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                required String id,
                required String userId,
                required String subjectId,
                required String examName,
                required double marksObtained,
                required double maxMarks,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InternalMarksCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                syncVersion: syncVersion,
                createdOffline: createdOffline,
                lastSyncedAt: lastSyncedAt,
                id: id,
                userId: userId,
                subjectId: subjectId,
                examName: examName,
                marksObtained: marksObtained,
                maxMarks: maxMarks,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InternalMarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InternalMarksTable,
      InternalMarkEntity,
      $$InternalMarksTableFilterComposer,
      $$InternalMarksTableOrderingComposer,
      $$InternalMarksTableAnnotationComposer,
      $$InternalMarksTableCreateCompanionBuilder,
      $$InternalMarksTableUpdateCompanionBuilder,
      (
        InternalMarkEntity,
        BaseReferences<_$AppDatabase, $InternalMarksTable, InternalMarkEntity>,
      ),
      InternalMarkEntity,
      PrefetchHooks Function()
    >;
typedef $$UserSettingsTableCreateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> syncVersion,
      Value<bool> createdOffline,
      Value<DateTime?> lastSyncedAt,
      required String id,
      required String userId,
      Value<bool> notificationsEnabled,
      Value<String> enabledModules,
      Value<String> theme,
      Value<String> preferences,
      Value<int> rowid,
    });
typedef $$UserSettingsTableUpdateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> syncVersion,
      Value<bool> createdOffline,
      Value<DateTime?> lastSyncedAt,
      Value<String> id,
      Value<String> userId,
      Value<bool> notificationsEnabled,
      Value<String> enabledModules,
      Value<String> theme,
      Value<String> preferences,
      Value<int> rowid,
    });

class $$UserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get createdOffline => $composableBuilder(
    column: $table.createdOffline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enabledModules => $composableBuilder(
    column: $table.enabledModules,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferences => $composableBuilder(
    column: $table.preferences,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get createdOffline => $composableBuilder(
    column: $table.createdOffline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enabledModules => $composableBuilder(
    column: $table.enabledModules,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferences => $composableBuilder(
    column: $table.preferences,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get createdOffline => $composableBuilder(
    column: $table.createdOffline,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get enabledModules => $composableBuilder(
    column: $table.enabledModules,
    builder: (column) => column,
  );

  GeneratedColumn<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<String> get preferences => $composableBuilder(
    column: $table.preferences,
    builder: (column) => column,
  );
}

class $$UserSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserSettingsTable,
          UserSettingsEntity,
          $$UserSettingsTableFilterComposer,
          $$UserSettingsTableOrderingComposer,
          $$UserSettingsTableAnnotationComposer,
          $$UserSettingsTableCreateCompanionBuilder,
          $$UserSettingsTableUpdateCompanionBuilder,
          (
            UserSettingsEntity,
            BaseReferences<
              _$AppDatabase,
              $UserSettingsTable,
              UserSettingsEntity
            >,
          ),
          UserSettingsEntity,
          PrefetchHooks Function()
        > {
  $$UserSettingsTableTableManager(_$AppDatabase db, $UserSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> createdOffline = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<String> enabledModules = const Value.absent(),
                Value<String> theme = const Value.absent(),
                Value<String> preferences = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                syncVersion: syncVersion,
                createdOffline: createdOffline,
                lastSyncedAt: lastSyncedAt,
                id: id,
                userId: userId,
                notificationsEnabled: notificationsEnabled,
                enabledModules: enabledModules,
                theme: theme,
                preferences: preferences,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> createdOffline = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                required String id,
                required String userId,
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<String> enabledModules = const Value.absent(),
                Value<String> theme = const Value.absent(),
                Value<String> preferences = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                syncVersion: syncVersion,
                createdOffline: createdOffline,
                lastSyncedAt: lastSyncedAt,
                id: id,
                userId: userId,
                notificationsEnabled: notificationsEnabled,
                enabledModules: enabledModules,
                theme: theme,
                preferences: preferences,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserSettingsTable,
      UserSettingsEntity,
      $$UserSettingsTableFilterComposer,
      $$UserSettingsTableOrderingComposer,
      $$UserSettingsTableAnnotationComposer,
      $$UserSettingsTableCreateCompanionBuilder,
      $$UserSettingsTableUpdateCompanionBuilder,
      (
        UserSettingsEntity,
        BaseReferences<_$AppDatabase, $UserSettingsTable, UserSettingsEntity>,
      ),
      UserSettingsEntity,
      PrefetchHooks Function()
    >;
typedef $$CalendarEventsTableCreateCompanionBuilder =
    CalendarEventsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> syncVersion,
      Value<bool> createdOffline,
      Value<DateTime?> lastSyncedAt,
      required String id,
      required String userId,
      required String title,
      required String type,
      required DateTime date,
      Value<String?> time,
      Value<String?> subjectId,
      Value<String?> location,
      Value<String?> notes,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$CalendarEventsTableUpdateCompanionBuilder =
    CalendarEventsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> syncVersion,
      Value<bool> createdOffline,
      Value<DateTime?> lastSyncedAt,
      Value<String> id,
      Value<String> userId,
      Value<String> title,
      Value<String> type,
      Value<DateTime> date,
      Value<String?> time,
      Value<String?> subjectId,
      Value<String?> location,
      Value<String?> notes,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$CalendarEventsTableFilterComposer
    extends Composer<_$AppDatabase, $CalendarEventsTable> {
  $$CalendarEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get createdOffline => $composableBuilder(
    column: $table.createdOffline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CalendarEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $CalendarEventsTable> {
  $$CalendarEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get createdOffline => $composableBuilder(
    column: $table.createdOffline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CalendarEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CalendarEventsTable> {
  $$CalendarEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get syncVersion => $composableBuilder(
    column: $table.syncVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get createdOffline => $composableBuilder(
    column: $table.createdOffline,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$CalendarEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CalendarEventsTable,
          CalendarEventEntity,
          $$CalendarEventsTableFilterComposer,
          $$CalendarEventsTableOrderingComposer,
          $$CalendarEventsTableAnnotationComposer,
          $$CalendarEventsTableCreateCompanionBuilder,
          $$CalendarEventsTableUpdateCompanionBuilder,
          (
            CalendarEventEntity,
            BaseReferences<
              _$AppDatabase,
              $CalendarEventsTable,
              CalendarEventEntity
            >,
          ),
          CalendarEventEntity,
          PrefetchHooks Function()
        > {
  $$CalendarEventsTableTableManager(
    _$AppDatabase db,
    $CalendarEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalendarEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalendarEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> createdOffline = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> time = const Value.absent(),
                Value<String?> subjectId = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarEventsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                syncVersion: syncVersion,
                createdOffline: createdOffline,
                lastSyncedAt: lastSyncedAt,
                id: id,
                userId: userId,
                title: title,
                type: type,
                date: date,
                time: time,
                subjectId: subjectId,
                location: location,
                notes: notes,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> syncVersion = const Value.absent(),
                Value<bool> createdOffline = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                required String id,
                required String userId,
                required String title,
                required String type,
                required DateTime date,
                Value<String?> time = const Value.absent(),
                Value<String?> subjectId = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalendarEventsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                syncVersion: syncVersion,
                createdOffline: createdOffline,
                lastSyncedAt: lastSyncedAt,
                id: id,
                userId: userId,
                title: title,
                type: type,
                date: date,
                time: time,
                subjectId: subjectId,
                location: location,
                notes: notes,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CalendarEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CalendarEventsTable,
      CalendarEventEntity,
      $$CalendarEventsTableFilterComposer,
      $$CalendarEventsTableOrderingComposer,
      $$CalendarEventsTableAnnotationComposer,
      $$CalendarEventsTableCreateCompanionBuilder,
      $$CalendarEventsTableUpdateCompanionBuilder,
      (
        CalendarEventEntity,
        BaseReferences<
          _$AppDatabase,
          $CalendarEventsTable,
          CalendarEventEntity
        >,
      ),
      CalendarEventEntity,
      PrefetchHooks Function()
    >;
typedef $$LectureEvidenceTableCreateCompanionBuilder =
    LectureEvidenceCompanion Function({
      required String id,
      required String lectureRecordId,
      required String localPathRelative,
      required String sha256,
      required int width,
      required int height,
      required DateTime captureTimestamp,
      required String appVersion,
      required String timezone,
      Value<String> state,
      Value<int> rowid,
    });
typedef $$LectureEvidenceTableUpdateCompanionBuilder =
    LectureEvidenceCompanion Function({
      Value<String> id,
      Value<String> lectureRecordId,
      Value<String> localPathRelative,
      Value<String> sha256,
      Value<int> width,
      Value<int> height,
      Value<DateTime> captureTimestamp,
      Value<String> appVersion,
      Value<String> timezone,
      Value<String> state,
      Value<int> rowid,
    });

class $$LectureEvidenceTableFilterComposer
    extends Composer<_$AppDatabase, $LectureEvidenceTable> {
  $$LectureEvidenceTableFilterComposer({
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

  ColumnFilters<String> get lectureRecordId => $composableBuilder(
    column: $table.lectureRecordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPathRelative => $composableBuilder(
    column: $table.localPathRelative,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get captureTimestamp => $composableBuilder(
    column: $table.captureTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LectureEvidenceTableOrderingComposer
    extends Composer<_$AppDatabase, $LectureEvidenceTable> {
  $$LectureEvidenceTableOrderingComposer({
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

  ColumnOrderings<String> get lectureRecordId => $composableBuilder(
    column: $table.lectureRecordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPathRelative => $composableBuilder(
    column: $table.localPathRelative,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get captureTimestamp => $composableBuilder(
    column: $table.captureTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LectureEvidenceTableAnnotationComposer
    extends Composer<_$AppDatabase, $LectureEvidenceTable> {
  $$LectureEvidenceTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lectureRecordId => $composableBuilder(
    column: $table.lectureRecordId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPathRelative => $composableBuilder(
    column: $table.localPathRelative,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<DateTime> get captureTimestamp => $composableBuilder(
    column: $table.captureTimestamp,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);
}

class $$LectureEvidenceTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LectureEvidenceTable,
          LectureEvidenceEntity,
          $$LectureEvidenceTableFilterComposer,
          $$LectureEvidenceTableOrderingComposer,
          $$LectureEvidenceTableAnnotationComposer,
          $$LectureEvidenceTableCreateCompanionBuilder,
          $$LectureEvidenceTableUpdateCompanionBuilder,
          (
            LectureEvidenceEntity,
            BaseReferences<
              _$AppDatabase,
              $LectureEvidenceTable,
              LectureEvidenceEntity
            >,
          ),
          LectureEvidenceEntity,
          PrefetchHooks Function()
        > {
  $$LectureEvidenceTableTableManager(
    _$AppDatabase db,
    $LectureEvidenceTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LectureEvidenceTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LectureEvidenceTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LectureEvidenceTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> lectureRecordId = const Value.absent(),
                Value<String> localPathRelative = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<int> width = const Value.absent(),
                Value<int> height = const Value.absent(),
                Value<DateTime> captureTimestamp = const Value.absent(),
                Value<String> appVersion = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LectureEvidenceCompanion(
                id: id,
                lectureRecordId: lectureRecordId,
                localPathRelative: localPathRelative,
                sha256: sha256,
                width: width,
                height: height,
                captureTimestamp: captureTimestamp,
                appVersion: appVersion,
                timezone: timezone,
                state: state,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String lectureRecordId,
                required String localPathRelative,
                required String sha256,
                required int width,
                required int height,
                required DateTime captureTimestamp,
                required String appVersion,
                required String timezone,
                Value<String> state = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LectureEvidenceCompanion.insert(
                id: id,
                lectureRecordId: lectureRecordId,
                localPathRelative: localPathRelative,
                sha256: sha256,
                width: width,
                height: height,
                captureTimestamp: captureTimestamp,
                appVersion: appVersion,
                timezone: timezone,
                state: state,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LectureEvidenceTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LectureEvidenceTable,
      LectureEvidenceEntity,
      $$LectureEvidenceTableFilterComposer,
      $$LectureEvidenceTableOrderingComposer,
      $$LectureEvidenceTableAnnotationComposer,
      $$LectureEvidenceTableCreateCompanionBuilder,
      $$LectureEvidenceTableUpdateCompanionBuilder,
      (
        LectureEvidenceEntity,
        BaseReferences<
          _$AppDatabase,
          $LectureEvidenceTable,
          LectureEvidenceEntity
        >,
      ),
      LectureEvidenceEntity,
      PrefetchHooks Function()
    >;
typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      required String name,
      required String email,
      Value<String?> profilePhoto,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> email,
      Value<String?> profilePhoto,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
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

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profilePhoto => $composableBuilder(
    column: $table.profilePhoto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
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

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profilePhoto => $composableBuilder(
    column: $table.profilePhoto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
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

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get profilePhoto => $composableBuilder(
    column: $table.profilePhoto,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          UserEntity,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (UserEntity, BaseReferences<_$AppDatabase, $UsersTable, UserEntity>),
          UserEntity,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String?> profilePhoto = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                name: name,
                email: email,
                profilePhoto: profilePhoto,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String email,
                Value<String?> profilePhoto = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                name: name,
                email: email,
                profilePhoto: profilePhoto,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      UserEntity,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (UserEntity, BaseReferences<_$AppDatabase, $UsersTable, UserEntity>),
      UserEntity,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueItemsTableCreateCompanionBuilder =
    SyncQueueItemsCompanion Function({
      Value<int> id,
      required String recordId,
      required String operation,
      Value<int> retryCount,
      Value<DateTime> createdAt,
      Value<DateTime?> lastAttempt,
      Value<String?> error,
      Value<bool> isSynced,
    });
typedef $$SyncQueueItemsTableUpdateCompanionBuilder =
    SyncQueueItemsCompanion Function({
      Value<int> id,
      Value<String> recordId,
      Value<String> operation,
      Value<int> retryCount,
      Value<DateTime> createdAt,
      Value<DateTime?> lastAttempt,
      Value<String?> error,
      Value<bool> isSynced,
    });

class $$SyncQueueItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueItemsTable> {
  $$SyncQueueItemsTableFilterComposer({
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

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttempt => $composableBuilder(
    column: $table.lastAttempt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueItemsTable> {
  $$SyncQueueItemsTableOrderingComposer({
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

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttempt => $composableBuilder(
    column: $table.lastAttempt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueItemsTable> {
  $$SyncQueueItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttempt => $composableBuilder(
    column: $table.lastAttempt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$SyncQueueItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueItemsTable,
          SyncQueueItem,
          $$SyncQueueItemsTableFilterComposer,
          $$SyncQueueItemsTableOrderingComposer,
          $$SyncQueueItemsTableAnnotationComposer,
          $$SyncQueueItemsTableCreateCompanionBuilder,
          $$SyncQueueItemsTableUpdateCompanionBuilder,
          (
            SyncQueueItem,
            BaseReferences<_$AppDatabase, $SyncQueueItemsTable, SyncQueueItem>,
          ),
          SyncQueueItem,
          PrefetchHooks Function()
        > {
  $$SyncQueueItemsTableTableManager(
    _$AppDatabase db,
    $SyncQueueItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastAttempt = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => SyncQueueItemsCompanion(
                id: id,
                recordId: recordId,
                operation: operation,
                retryCount: retryCount,
                createdAt: createdAt,
                lastAttempt: lastAttempt,
                error: error,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String recordId,
                required String operation,
                Value<int> retryCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastAttempt = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => SyncQueueItemsCompanion.insert(
                id: id,
                recordId: recordId,
                operation: operation,
                retryCount: retryCount,
                createdAt: createdAt,
                lastAttempt: lastAttempt,
                error: error,
                isSynced: isSynced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueItemsTable,
      SyncQueueItem,
      $$SyncQueueItemsTableFilterComposer,
      $$SyncQueueItemsTableOrderingComposer,
      $$SyncQueueItemsTableAnnotationComposer,
      $$SyncQueueItemsTableCreateCompanionBuilder,
      $$SyncQueueItemsTableUpdateCompanionBuilder,
      (
        SyncQueueItem,
        BaseReferences<_$AppDatabase, $SyncQueueItemsTable, SyncQueueItem>,
      ),
      SyncQueueItem,
      PrefetchHooks Function()
    >;
typedef $$SyncMetadataTableCreateCompanionBuilder =
    SyncMetadataCompanion Function({
      required String key,
      Value<String?> value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SyncMetadataTableUpdateCompanionBuilder =
    SyncMetadataCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SyncMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetadataTable,
          SyncMetadataEntity,
          $$SyncMetadataTableFilterComposer,
          $$SyncMetadataTableOrderingComposer,
          $$SyncMetadataTableAnnotationComposer,
          $$SyncMetadataTableCreateCompanionBuilder,
          $$SyncMetadataTableUpdateCompanionBuilder,
          (
            SyncMetadataEntity,
            BaseReferences<
              _$AppDatabase,
              $SyncMetadataTable,
              SyncMetadataEntity
            >,
          ),
          SyncMetadataEntity,
          PrefetchHooks Function()
        > {
  $$SyncMetadataTableTableManager(_$AppDatabase db, $SyncMetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetadataTable,
      SyncMetadataEntity,
      $$SyncMetadataTableFilterComposer,
      $$SyncMetadataTableOrderingComposer,
      $$SyncMetadataTableAnnotationComposer,
      $$SyncMetadataTableCreateCompanionBuilder,
      $$SyncMetadataTableUpdateCompanionBuilder,
      (
        SyncMetadataEntity,
        BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataEntity>,
      ),
      SyncMetadataEntity,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SemestersTableTableManager get semesters =>
      $$SemestersTableTableManager(_db, _db.semesters);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db, _db.subjects);
  $$TimetableTableTableManager get timetable =>
      $$TimetableTableTableManager(_db, _db.timetable);
  $$LectureRecordsTableTableManager get lectureRecords =>
      $$LectureRecordsTableTableManager(_db, _db.lectureRecords);
  $$AssignmentsTableTableManager get assignments =>
      $$AssignmentsTableTableManager(_db, _db.assignments);
  $$InternalMarksTableTableManager get internalMarks =>
      $$InternalMarksTableTableManager(_db, _db.internalMarks);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
  $$CalendarEventsTableTableManager get calendarEvents =>
      $$CalendarEventsTableTableManager(_db, _db.calendarEvents);
  $$LectureEvidenceTableTableManager get lectureEvidence =>
      $$LectureEvidenceTableTableManager(_db, _db.lectureEvidence);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$SyncQueueItemsTableTableManager get syncQueueItems =>
      $$SyncQueueItemsTableTableManager(_db, _db.syncQueueItems);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
}
