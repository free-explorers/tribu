import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tribu/data/common.providers.dart';
import 'package:tribu/data/encryptable.dart';
import 'package:tribu/data/tribu/tool/list/aggregated_list_item.model.dart';
import 'package:tribu/utils/encryption/encryption.dart';

part 'tool.model.freezed.dart';
part 'tool.model.g.dart';

enum ToolType {
  @JsonValue('list')
  list,
  @JsonValue('expenses')
  expenses,
}

/* abstract class Tool {
  String? get id;
  String get name;
  ToolType get type;
} */

@Freezed(unionKey: 'type', unionValueCase: FreezedUnionCase.snake)
class Tool with _$Tool implements Encryptable {
  Tool._();

  @JsonSerializable(explicitToJson: true)
  factory Tool.list({
    required String name,
    required String icon,
    String? id,
    @Default(AggregatedListItem()) @JsonKey() AggregatedListItem aggregated,
  }) = ListTool;

  factory Tool.expenses({
    required String name,
    required String currency,
    String? id,
  }) = ExpensesTool;

  factory Tool.fromJson(Map<String, dynamic> json) => _$ToolFromJson(json);
  factory Tool.fromEncryptedJson(
    Map<String, dynamic> json,
    String encryptionKey,
  ) {
    json.update(
      'name',
      (encryptedString) =>
          EncryptionManager.decrypt(encryptedString as String, encryptionKey),
    );
    return Tool.fromJson(json);
  }

  @override
  Json encrypt(String encryptionKey) {
    final json = toJson();
    return EncryptionManager.encryptFields(
      json,
      ['name'],
      encryptionKey,
    );
  }
}
