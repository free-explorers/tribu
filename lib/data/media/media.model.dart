import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'media.model.freezed.dart';
part 'media.model.g.dart';

@freezed
class Media with _$Media {
  @HiveType(typeId: 1)
  const factory Media({
    @HiveField(2) required String mime,
    @HiveField(3) required DateTime createdAt,
    @HiveField(0) String? localPath,
    @HiveField(1) String? remoteUrl,
    @HiveField(4) Map<String, dynamic>? additionalData,
  }) = _Media;
  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);
}
