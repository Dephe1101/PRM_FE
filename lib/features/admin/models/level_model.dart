import 'package:freezed_annotation/freezed_annotation.dart';

part 'level_model.freezed.dart';
part 'level_model.g.dart';

@freezed
abstract class LevelModel with _$LevelModel {
  const factory LevelModel({
    @JsonKey(name: '_id') required String id,
    required String name,
    @Default('') String description,
    required int orderIndex,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _LevelModel;

  factory LevelModel.fromJson(Map<String, dynamic> json) => _$LevelModelFromJson(json);
}
