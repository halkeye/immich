import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:immich_mobile/shared/models/asset.dart';
import 'package:immich_mobile/modules/memories/models/memory.dart';
import 'package:immich_mobile/shared/providers/api.provider.dart';
import 'package:immich_mobile/shared/services/api.service.dart';
import 'package:logging/logging.dart';
import 'package:openapi/api.dart';

final memoryServiceProvider = StateProvider<MemoryService>((ref) {
  return MemoryService(
    ref.watch(apiServiceProvider),
  );
});

class MemoryService {
  final log = Logger("MemoryService");

  final ApiService _apiService;

  MemoryService(this._apiService);

  Future<List<Memory>?> getMemoryLane() async {
    try {
      final now = DateTime.now();
      final data = await _apiService.assetApi.getMemoryLane(
        now.day,
        now.month,
      );

      if (data == null) {
        return null;
      }

      List<Memory> memories = [];
      for (final MemoryLaneResponseDto(:title, :assets) in data) {
        memories.add(
          Memory(
            title: title,
            assets: assets.map((e) => Asset.remote(e)).toList(),
          ),
        );
      }

      return memories.isNotEmpty ? memories : null;
    } catch (error, stack) {
      log.severe("Cannot get memories", error, stack);
      return null;
    }
  }
}
