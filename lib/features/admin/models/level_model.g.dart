// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LevelModel _$LevelModelFromJson(Map<String, dynamic> json) => _LevelModel(
  id: json['_id'] as String,
  name: json['name'] as String,
  description: json['description'] as String? ?? '',
  orderIndex: (json['orderIndex'] as num).toInt(),
  isActive: json['isActive'] as bool? ?? true,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$LevelModelToJson(_LevelModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'orderIndex': instance.orderIndex,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
