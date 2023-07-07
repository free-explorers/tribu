import 'package:freezed_annotation/freezed_annotation.dart';

part 'keep_alive_signal.model.freezed.dart';
part 'keep_alive_signal.model.g.dart';

@freezed
class KeepAliveSignal with _$KeepAliveSignal {
  const factory KeepAliveSignal({required String from}) = _KeepAliveSignal;
  factory KeepAliveSignal.fromJson(Map<String, dynamic> json) =>
      _$KeepAliveSignalFromJson(json);
}
