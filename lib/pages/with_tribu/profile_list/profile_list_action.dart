import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tribu/widgets/utils/selectable_list.widget.dart';

part 'profile_list_action.freezed.dart';

@freezed
class ProfileListAction with _$ProfileListAction {
  const factory ProfileListAction({
    required String title,
    required SelectionMode selectionMode,
  }) = _ProfileListAction;

  /* factory ProfileListAction.decrypt(
      EncryptedMessage encryptedMessage, encryptionKey) {
    final decryptedData = EncryptionManager.decrypt(
        encryptedMessage.encryptedContent, encryptionKey);
    return ProfileListAction(
        forUserId: encryptedMessage.forUserId,
        fromUserId: encryptedMessage.fromUserId,
        tribuId: encryptedMessage.tribuId,
        content: jsonDecode(decryptedData));
  } */
}
