import 'package:flutter_riverpod/flutter_riverpod.dart';

class TestNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() async => 1;
}

final testProvider = AsyncNotifierProvider.autoDispose<TestNotifier, int>(() => TestNotifier());
