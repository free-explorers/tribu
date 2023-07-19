import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:tribu/data/tribu/event/event.model.dart';
import 'package:tribu/data/tribu/event/event_list.notifier.dart';
import 'package:tribu/data/tribu/profile/profile_list.notifier.dart';
import 'package:tribu/data/tribu/tool/expenses/expense/expense.model.dart';
import 'package:tribu/data/tribu/tool/expenses/expense_list.notifier.dart';
import 'package:tribu/data/tribu/tool/list/item/list_item.model.dart';
import 'package:tribu/data/tribu/tool/list/list_tool.manager.dart';
import 'package:tribu/data/tribu/tool/tool.model.dart';
import 'package:tribu/data/tribu/tool/tool_list.notifier.dart';
import 'package:tribu/data/tribu/tribu_list.notifier.dart';
import 'package:tribu/generated/l10n.dart';
import 'package:tribu/utils/encryption/encryption.dart';

const currentModelVersion = 2;

const migrationFrom = {1: migration1to2};

/// Changes:
/// * New Event Model with dedicated encryption key
/// * Tools are now bundled in an Event and encrypted with their event dedicated
///   encryption key
/// Strategy:
/// * Create a single Event for "Daily routine" and reencrypt all tools with the
///   event encryption key
Future<void> migration1to2(String tribuId) async {
  final tribuEncryptionKey = await EncryptionManager.getKey(tribuId);
  final toolCollectionWithTribuKey =
      ToolListNotifier.getCollection(tribuId, tribuEncryptionKey);

  final profileList =
      (await ProfileListNotifier.getCollection(tribuId, tribuEncryptionKey)
              .get())
          .docs
          .map((e) => e.data())
          .toList();
  final toolList = (await toolCollectionWithTribuKey.get())
      .docs
      .map((e) => e.data())
      .toList();

  final toolDataMap = <String, List<dynamic>>{};
  for (final tool in toolList) {
    if (tool is ListTool) {
      final collection = ListToolManager.getCollection(
        tribuId,
        tool.id!,
        tribuEncryptionKey,
      );
      toolDataMap[tool.id!] =
          (await collection.get()).docs.map((e) => e.data()).toList();
    }
    if (tool is ExpensesTool) {
      final collection = ExpenseListNotifier.getCollection(
        tribuId,
        tool.id!,
        tribuEncryptionKey,
      );
      toolDataMap[tool.id!] =
          (await collection.get()).docs.map((e) => e.data()).toList();
    }
  }

  final eventDoc =
      EventListNotifier.getCollection(tribuId, tribuEncryptionKey).doc();

  await FirebaseFirestore.instance.runTransaction((transaction) async {
    // First check that the tribu model is still 1
    final tribuDoc = TribuListNotifier.getCollection().doc(tribuId);

    final tribu = (await transaction.get(tribuDoc)).data();
    if (tribu == null || tribu.modelVersion != 1) return;

    // get all tools

    final eventEncryptionKey = Key.fromSecureRandom(32).base64;

    final event = PermanentEvent(
      title: S.current.defaultPermanentEventName,
      toolIdList: toolList.map((e) => e.id!).toList(),
      createdAt: DateTime.now(),
      encryptionKey: eventEncryptionKey,
    );

    transaction.set(eventDoc, event);
    final toolCollectionWithEventKey =
        ToolListNotifier.getCollection(tribuId, eventEncryptionKey);

    for (final tool in toolList) {
      final toolDoc = toolCollectionWithEventKey.doc(tool.id);
      transaction.set(toolDoc, tool);
      if (tool is ListTool) {
        final collection = ListToolManager.getCollection(
          tribuId,
          tool.id!,
          eventEncryptionKey,
        );
        for (final item in toolDataMap[tool.id!]! as List<ListItem>) {
          transaction.set(collection.doc(item.id), item);
        }
      }
      if (tool is ExpensesTool) {
        final collection = ExpenseListNotifier.getCollection(
          tribuId,
          tool.id!,
          eventEncryptionKey,
        );
        for (var item in toolDataMap[tool.id!]! as List<Expense>) {
          if (item.paidFor.isEmpty) {
            item = item.copyWith(
              paidFor: profileList
                  .where(
                    (profile) =>
                        !(profile.disabled ?? false) &&
                        profile.mergedInto == null,
                  )
                  .map((e) => e.id)
                  .toList(),
            );
          }
          transaction.set(collection.doc(item.id), item);
        }
      }
    }

    transaction.set(tribuDoc, tribu.copyWith(modelVersion: 2));

    return null;
  });
}
