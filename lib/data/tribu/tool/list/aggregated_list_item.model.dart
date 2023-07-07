import 'package:freezed_annotation/freezed_annotation.dart';

part 'aggregated_list_item.model.freezed.dart';
part 'aggregated_list_item.model.g.dart';

@freezed
class AggregatedListItem with _$AggregatedListItem {
  const factory AggregatedListItem({
    @Default(0) int length,
    int? checkedLength,
  }) = _AggregatedListItem;

  factory AggregatedListItem.fromJson(Map<String, dynamic> json) =>
      _$AggregatedListItemFromJson(json);
}
