import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCacheManager {
  static const key = 'customCacheForVideo';
  static final CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 30, // Maximum number of files
      //maxCacheSize: 100 * 1024 * 1024, // Maximum size of cache (100 MB)
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
}

Future<String> downloadAndCacheVideo(String url) async {
  FileInfo fileInfo = await CustomCacheManager.instance.downloadFile(url);
  return fileInfo.file.path;
}
