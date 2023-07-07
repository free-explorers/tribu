import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tribu/data/user/user.manager.dart';
import 'package:tribu/data/user/user.model.dart';

final userProvider = StateNotifierProvider<UserNotifier, TribuUser?>(
    (ref) => throw Exception('Provider was not initialized'),);
