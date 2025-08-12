import 'dart:typed_data';
import 'package:aura_clean/models/photo_asset.dart';
import 'package:crypto/crypto.dart';
import 'package:photo_manager/photo_manager.dart';

class PhotoRepository {
  Future<List<PhotoAsset>> getAllPhotos() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.common,
      );
      final List<PhotoAsset> allAssets = [];
      for (final album in albums) {
        final int count = await album.assetCountAsync;
        final List<AssetEntity> assets = await album.getAssetListRange(
          start: 0,
          end: count,
        );
        allAssets.addAll(assets.map((e) => PhotoAsset.fromEntity(e)));
      }
      return allAssets;
    } else {
      PhotoManager.openSetting();
      return [];
    }
  }

  Future<List<PhotoAsset>> findDuplicatePhotos(List<PhotoAsset> assets) async {
    final imageAssets = assets.where((a) => a.type == AssetType.image).toList();
    final Map<String, List<PhotoAsset>> hashes = {};

    for (final asset in imageAssets) {
      final Uint8List? thumbData = await asset.entity.thumbnailData;
      if (thumbData != null) {
        final String hash = md5.convert(thumbData).toString();
        if (hashes.containsKey(hash)) {
          hashes[hash]!.add(asset);
        } else {
          hashes[hash] = [asset];
        }
      }
    }

    final List<PhotoAsset> duplicates = [];
    hashes.values.where((group) => group.length > 1).forEach(duplicates.addAll);

    return duplicates;
  }

  Future<List<PhotoAsset>> findSimilarPhotos(List<PhotoAsset> assets) async {
    final imageAssets = assets.where((a) => a.type == AssetType.image).toList();
    imageAssets.sort((a, b) => (a.createDateTime ?? DateTime.now()).compareTo(b.createDateTime ?? DateTime.now()));

    final List<PhotoAsset> similar = [];
    for (int i = 0; i < imageAssets.length - 1; i++) {
      final DateTime? date1 = imageAssets[i].createDateTime;
      final DateTime? date2 = imageAssets[i+1].createDateTime;
      if (date1 != null && date2 != null) {
        final Duration difference = date2.difference(date1);
        if (difference.inSeconds < 60) {
          if (!similar.contains(imageAssets[i])) similar.add(imageAssets[i]);
          if (!similar.contains(imageAssets[i+1])) similar.add(imageAssets[i+1]);
        }
      }
    }
    return similar;
  }

  Future<List<PhotoAsset>> findScreenshots(List<PhotoAsset> assets) async {
    final List<PhotoAsset> screenshots = [];
    for(final asset in assets) {
      // For now, we'll identify screenshots by checking if they're in a screenshots folder
      // This is a simplified approach - in a real app you might want to use metadata or other heuristics
      if (asset.type == AssetType.image) {
        // Check if the asset might be a screenshot based on common patterns
        // This is a placeholder implementation
        screenshots.add(asset);
      }
    }
    return screenshots;
  }

  Future<List<PhotoAsset>> findLargeVideos(List<PhotoAsset> assets) async {
    final videoAssets = assets.where((a) => a.type == AssetType.video).toList();
    videoAssets.sort((a, b) => b.size.compareTo(a.size));
    return videoAssets.where((v) => v.size > 100 * 1024 * 1024).toList();
  }

  Future<void> deletePhotos(List<PhotoAsset> assets) async {
    final List<String> idsToDelete = assets.map((a) => a.id).toList();
    if (idsToDelete.isNotEmpty) {
      await PhotoManager.editor.deleteWithIds(idsToDelete);
    }
  }

  PhotoAsset? findBestPhoto(List<PhotoAsset> photos) {
    if (photos.isEmpty) return null;
    photos.sort((a, b) => b.size.compareTo(a.size));
    return photos.first;
  }
}
