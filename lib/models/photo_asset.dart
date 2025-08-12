import 'package:equatable/equatable.dart';
import 'package:photo_manager/photo_manager.dart';

class PhotoAsset extends Equatable {
  final AssetEntity entity;
  final String id;
  final int width;
  final int height;
  final int size;
  final DateTime? createDateTime;
  final AssetType? type;

  const PhotoAsset({
    required this.entity,
    required this.id,
    required this.width,
    required this.height,
    required this.size,
    this.createDateTime,
    this.type,
  });

  factory PhotoAsset.fromEntity(AssetEntity entity) {
    return PhotoAsset(
      entity: entity,
      id: entity.id,
      width: entity.width,
      height: entity.height,
      size: entity.size.width.toInt(),
      createDateTime: entity.createDateTime,
      type: entity.type,
    );
  }

  @override
  List<Object?> get props => [id, createDateTime, size];
}
