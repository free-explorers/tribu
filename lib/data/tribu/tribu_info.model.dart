import 'package:freezed_annotation/freezed_annotation.dart';

part 'tribu_info.model.freezed.dart';
part 'tribu_info.model.g.dart';

@freezed
class TribuInfo with _$TribuInfo {
  factory TribuInfo(
      {required String tribuId,
      required int unreadMessage,
      required DateTime lastRead,}) = _TribuInfo;
  factory TribuInfo.fromJson(Map<String, dynamic> json) =>
      _$TribuInfoFromJson(json);
}
